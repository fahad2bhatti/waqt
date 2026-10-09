package com.fahadapps.waqt

import android.content.Context
import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.plugin.common.EventChannel
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sin

/** Streams the phone's true-north heading (degrees, 0..360) and sensor accuracy to Flutter. */
class CompassStream(context: Context) : EventChannel.StreamHandler, SensorEventListener {
    private val sensorManager =
        context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private var sink: EventChannel.EventSink? = null
    private var declination = 0f
    private val rotation = FloatArray(9)

    // Low-pass filter on the unit vector, so 359 -> 1 degrees does not jump.
    private var sinFiltered = 0.0
    private var cosFiltered = 0.0
    private var hasValue = false

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        val sensor = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        if (sensor == null) {
            events.error("NO_SENSOR", "This phone has no compass sensor", null)
            return
        }

        val args = arguments as? Map<*, *>
        val lat = (args?.get("lat") as? Number)?.toFloat() ?: 0f
        val lon = (args?.get("lon") as? Number)?.toFloat() ?: 0f
        declination = GeomagneticField(lat, lon, 0f, System.currentTimeMillis()).declination

        sink = events
        hasValue = false
        sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_UI)
    }

    override fun onCancel(arguments: Any?) {
        sensorManager.unregisterListener(this)
        sink = null
    }

    override fun onSensorChanged(event: SensorEvent) {
        SensorManager.getRotationMatrixFromVector(rotation, event.values)

        // Phone flat: use the top edge. Phone upright: use the back (camera side).
        val flat = abs(rotation[8]) > 0.75f
        val east = if (flat) rotation[1] else -rotation[2]
        val north = if (flat) rotation[4] else -rotation[5]
        val radians = atan2(east.toDouble(), north.toDouble())

        if (!hasValue) {
            sinFiltered = sin(radians)
            cosFiltered = cos(radians)
            hasValue = true
        } else {
            sinFiltered += ALPHA * (sin(radians) - sinFiltered)
            cosFiltered += ALPHA * (cos(radians) - cosFiltered)
        }

        val magnetic = Math.toDegrees(atan2(sinFiltered, cosFiltered))
        val trueHeading = ((magnetic + declination) % 360 + 360) % 360

        sink?.success(
            mapOf(
                "heading" to trueHeading,
                "accuracy" to event.accuracy,
            ),
        )
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    private companion object {
        const val ALPHA = 0.2
    }
}
