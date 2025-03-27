package com.example.spotify.data.viewmodel

import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import android.net.Uri
import android.util.Log
import com.arthenica.ffmpegkit.FFmpegKit
import com.arthenica.ffmpegkit.FFmpegKitConfig.enableStatisticsCallback
import com.arthenica.ffmpegkit.FFmpegSession
import com.arthenica.ffmpegkit.FFmpegSessionCompleteCallback
import com.arthenica.ffmpegkit.ReturnCode
import com.example.spotify.AppConstants
import com.example.spotify.data.model.MovieEpisode
import com.example.spotify.data.model.Status
import com.example.spotify.data.model.StatusEnum
import com.google.gson.Gson
import java.util.*
import kotlin.collections.ArrayList

interface IEventListener{
    fun onDownload(currentMovieEpisode: MovieEpisode)
    fun onDownloaded()
}

class DownloadViewModel(private val listener: IEventListener) {

    private val moviesWaiting: Queue<MovieEpisode> = LinkedList()
    private var currentMovie: MovieEpisode? = null

    init {
        listenDownloadExecuteProcess()
    }

    fun checkAndRestartDownload(){
        if(currentMovie == null) {
            startDownload()
        }
    }

    fun addData(applicationContext: Context, movie: MovieEpisode){
        if(currentMovie?.id == movie.id) return

        val movieWaiting: MovieEpisode? = moviesWaiting.firstOrNull { it.id == movie.id }
        if(movieWaiting == null){
            movie.totalSecondTime = getTotalTimeUrlMovie(applicationContext, movie.url)
            moviesWaiting.add(movie)
        }else if(movieWaiting.status.status != StatusEnum.INITIALIZATION){
            movieWaiting.status = Status.Initialization()
        }

        if(currentMovie != null) return     /// if downloading -> return

        startDownload()
    }

    fun cancelDownload(movie: MovieEpisode){
        Log.e("cancelDownload", "${movie.id}")
        if(movie.id == currentMovie?.id){
            FFmpegKit.cancel()
        }else{
            moviesWaiting.forEach {
                if(it.id == movie.id){
                    it.status = Status.Cancel("Download has cancel", "")
                }
            }
        }
    }

    private fun startDownload(){
        currentMovie = moviesWaiting.poll()
        if(currentMovie == null) {
            listener.onDownloaded()
            return
        }else if(currentMovie?.status?.status !=  StatusEnum.INITIALIZATION){
            startDownload()
            return
        }

        FFmpegKit.executeAsync(
            "-i ${currentMovie!!.url} -c:v mpeg4 -y ${currentMovie!!.localPath}"
        ) {
            when (it.returnCode.value) {
                ReturnCode.SUCCESS -> {
                    listener.onDownload(
                        currentMovie!!.apply {
                            status = Status.Success("Download completed successfully")
                        })
                }
                ReturnCode.CANCEL -> {
                    listener.onDownload(
                        currentMovie!!.apply {
                            status = Status.Cancel("Download canceled", "")
                        })
                }
                else -> {
                    listener.onDownload(
                        currentMovie!!.apply {
                            status = Status.Error("Download failed", "")
                        })
                }
            }
            startDownload()
        }
    }

    private fun getTotalTimeUrlMovie(applicationContext: Context, url: String?): Int{
        if (url.isNullOrEmpty()) {
            return 0
        }
        val mediaPlayer: MediaPlayer = MediaPlayer.create(applicationContext, Uri.parse(url))
        val totalTime = mediaPlayer.duration
        mediaPlayer.release()
        return totalTime
    }

    private fun listenDownloadExecuteProcess(){
        enableStatisticsCallback { newStatistics ->
            if(currentMovie == null) return@enableStatisticsCallback

            currentMovie!!.currentSecondTime = newStatistics.time.toInt()
            Log.e("progress", "current: ${currentMovie!!.currentSecondTime}, total: $${currentMovie!!.totalSecondTime} - process: $${currentMovie!!.executeProcess}")
            listener.onDownload(
                currentMovie!!.apply {
                    status = Status.Loading("Downloading")
                }
            )
        }
    }

    fun sendActionToActivity(applicationContext: Context, event: MovieEpisode) {
        val intent = Intent(AppConstants.ACTION_DOWNLOAD)
        intent.setPackage(applicationContext.packageName)
        val arrayProcess = ArrayList<MovieEpisode>();
        arrayProcess.add(event)
        arrayProcess.addAll(moviesWaiting)
        val jsonData: String = Gson().toJson(arrayProcess)
        intent.putExtra(AppConstants.DOWNLOAD_SERVICE_DATA, jsonData)
        applicationContext.sendBroadcast(intent)
    }
}