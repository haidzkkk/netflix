package com.example.spotify

import android.app.Notification
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import com.example.spotify.data.model.MovieEpisode
import com.example.spotify.data.model.Status
import com.example.spotify.data.model.StatusEnum
import com.example.spotify.data.viewmodel.DownloadViewModel
import com.example.spotify.data.viewmodel.IEventListener
import com.google.gson.Gson


class DownloadService : Service() {
    lateinit var viewMode: DownloadViewModel

    override fun onBind(p0: Intent?): IBinder? = null

    override fun onCreate() {
        viewMode = DownloadViewModel(object: IEventListener{
            override fun onDownload(currentMovieEpisode: MovieEpisode) {
                viewMode.sendActionToActivity(applicationContext, currentMovieEpisode)
                when(currentMovieEpisode.status.status){
                    StatusEnum.LOADING -> {
                        showNotifyForeground(
                            title = "${currentMovieEpisode.status.data} (${currentMovieEpisode.executeProcess}%)",
                            message = currentMovieEpisode.movieName ?: ""
                        )
                    }
                    StatusEnum.SUCCESS -> {
                        showNotify(
                            title = currentMovieEpisode.status.data ?: "",
                            message = currentMovieEpisode.movieName ?: ""
                        )
                    }
                    StatusEnum.ERROR -> {
                        showNotify(
                            title = currentMovieEpisode.status.data ?: "",
                            message = currentMovieEpisode.movieName ?: ""
                        )
                    }
                    StatusEnum.CANCEL -> {
                        showNotify(
                            title = currentMovieEpisode.status.data ?: "",
                            message = currentMovieEpisode.movieName ?: ""
                        )
                    }
                    else -> {
                        showNotifyForeground()
                    }
                }
            }
            override fun onDownloaded() {
                stopSelf()
            }
        })
        super.onCreate()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val movieEpisode: MovieEpisode? = intent?.getStringExtra(AppConstants.DOWNLOAD_SERVICE_DATA)?.let { jsonData ->
            Gson().fromJson(jsonData, MovieEpisode::class.java).apply {
                this.status = Status.Initialization()
            }
        }
        when(intent?.action){
            AppConstants.INVOKE_METHOD_START_SERVICE -> {
                if(movieEpisode != null){
                    viewMode.addData(applicationContext, movieEpisode)
                }
            }
            AppConstants.INVOKE_METHOD_CANCEL_MOVIE_EPISODE -> {
                if(movieEpisode != null){
                    viewMode.cancelDownload(movieEpisode)
                }
            }
            else -> {
                viewMode.checkAndRestartDownload()
            }
        }

        showNotifyForeground(
            message = "Đang chờ ${movieEpisode?.movieName ?: ""}"
        )
        return START_STICKY
    }

    fun showNotify(title: String, message: String){
        val notification: Notification = NotificationCompat.Builder(this, AppConstants.CHANNEL_ID)
            .setSmallIcon(R.mipmap.app_icon)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .build()

        (getSystemService(Context.NOTIFICATION_SERVICE) as (NotificationManager))
            .notify(0, notification)
    }

    fun showNotifyForeground(
        title: String = "Đang chạy dịch vụ download",
        message: String = "Không có phim để tải"
    ){
        val notification: Notification = NotificationCompat.Builder(this, AppConstants.CHANNEL_ID)
            .setSmallIcon(R.mipmap.app_icon)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .build()
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            startForeground(1, notification)
        } else {
            startForeground(1, notification,
                FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
        }
    }
}