import org.linphone.core.TransportType

data class SipConfiguration(
    val extension: String,
    val domain: String,
    val password: String,
    var port: Int = 5060,
    var transportType: String = TransportType.Udp.name,
    var isKeepAlive: Boolean = false
)