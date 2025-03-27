-keepclassmembers class com.example.spotify.data.model.MovieEpisode {
    <fields>;
}
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }

# Giữ nguyên tất cả các lớp và thuộc tính của `Status` và `StatusEnum`
-keep class com.example.spotify.data.model.Status { *; }
-keep class com.example.spotify.data.model.StatusEnum { *; }

# Giữ nguyên các lớp có annotation của Gson
-keep class com.google.gson.annotations.SerializedName
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Giữ nguyên tất cả các lớp model được serialize/deserialize
-keep class com.example.spotify.data.model.** { *; }
