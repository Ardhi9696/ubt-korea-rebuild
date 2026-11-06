package com.leeubt.ubtkorea.rebuild

import android.content.res.AssetFileDescriptor
import android.media.MediaPlayer
import android.media.PlaybackParams
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// MainActivity + pemutar audio test via MethodChannel.
///
/// Sengaja TANPA plugin audio pihak ketiga: just_audio 0.10.6 bikin
/// Flutter 3.47 melewatkan dependency embedding untuk modul app
/// (plugin ada -> embedding dianggap transitif, tapi tidak sampai ke
/// compile classpath MainActivity) sehingga build merah. MediaPlayer
/// bawaan Android cukup untuk satu file nada test.
class MainActivity : FlutterActivity() {
    private var mediaPlayer: MediaPlayer? = null
    private var audioChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        audioChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "ubt_korea_rebuild/audio",
        )
        audioChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "playTestTone" -> {
                    val speed = (call.argument<Double>("speed") ?: 1.0).toFloat()
                    playTestTone(speed)
                    result.success(null)
                }
                "setSpeed" -> {
                    val speed = (call.argument<Double>("speed") ?: 1.0).toFloat()
                    setSpeed(speed)
                    result.success(null)
                }
                "stopAudio" -> {
                    stopAudio()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun playTestTone(speed: Float) {
        stopAudio()
        try {
            val afd: AssetFileDescriptor =
                assets.openFd("flutter_assets/assets/audio/test_tone.mp3")
            val player = MediaPlayer()
            player.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
            afd.close()
            player.setOnCompletionListener {
                audioChannel?.invokeMethod("onAudioCompleted", null)
                stopAudio()
            }
            player.setOnErrorListener { _, _, _ ->
                audioChannel?.invokeMethod("onAudioCompleted", null)
                true
            }
            player.prepare()
            setSpeedOn(player, speed)
            player.start()
            mediaPlayer = player
        } catch (_: Exception) {
            // File tidak bisa diputar: beri tahu Dart supaya soal tidak macet.
            audioChannel?.invokeMethod("onAudioCompleted", null)
        }
    }

    private fun setSpeedOn(player: MediaPlayer, speed: Float) {
        try {
            val params = player.playbackParams ?: PlaybackParams()
            params.speed = speed
            player.playbackParams = params
        } catch (_: Exception) {
            // Perangkat/format tak mendukung perubahan kecepatan: abaikan.
        }
    }

    private fun setSpeed(speed: Float) {
        mediaPlayer?.let { setSpeedOn(it, speed) }
    }

    private fun stopAudio() {
        mediaPlayer?.let {
            try {
                if (it.isPlaying) it.stop()
            } catch (_: Exception) {
            }
            try {
                it.reset()
            } catch (_: Exception) {
            }
            try {
                it.release()
            } catch (_: Exception) {
            }
        }
        mediaPlayer = null
    }

    override fun onDestroy() {
        stopAudio()
        audioChannel?.setMethodCallHandler(null)
        audioChannel = null
        super.onDestroy()
    }
}
