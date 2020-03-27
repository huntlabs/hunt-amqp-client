/*
 * hunt-amqp-client: AMQP Client Library for D Programming Language. Support for RabbitMQ and other AMQP Server.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net
 *
 * Licensed under the Apache-2.0 License.
 *
 */
module hunt.amqp.client.AmqpClientOptions;

//import hunt.codegen.annotations.DataObject;
//import hunt.core.buffer.Buffer;
//import hunt.core.json.JsonObject;
//import hunt.core.net.*;
import hunt.amqp.ProtonClientOptions;

import hunt.collection.Set;
import core.time;

/**
 * Configures the AMQP Client.
 * You can also configure the underlying Proton instance. Refer to {@link ProtonClientOptions} for details.
 */
//@DataObject(generateConverter = true, inheritConverter = true)
class AmqpClientOptions : ProtonClientOptions {

    enum string DEFAULT_HOST = "localhost";
    enum int DEFAULT_PORT = 5672;
    enum int DEFAULT_SENTINEL_PORT = 26379;
    enum int DEFAULT_TIMEOUT = 2000;
    // https://www.rabbitmq.com/access-control.html
    enum string DEFAULT_USERNAME = "guest";
    enum string DEFAULT_PASSWORD = "guest";

    // TODO Capabilities and properties

    private string host = DEFAULT_HOST;//= getFromSysOrEnv("amqp-client-host");
    private int port = DEFAULT_PORT;//= getPortFromSysOrEnv();

    private string username = DEFAULT_USERNAME;// = getFromSysOrEnv("amqp-client-username");
    private string password = DEFAULT_PASSWORD;// = getFromSysOrEnv("amqp-client-password");

    private string containerId ;//= UUID.randomUUID().toString();

    this() {
        super();
        setConnectTimeout(10.seconds);
        setIdleTimeout(10.seconds);
    }

    //AmqpClientOptions(JsonObject json) {
    //  super(json);
    //  AmqpClientOptionsConverter.fromJson(json, this);
    //}

    this(AmqpClientOptions other) {
        super(other);
        this.host = other.host;
        this.password = other.password;
        this.username = other.username;
        this.port = other.port;
        this.containerId = other.containerId;
    }

    //JsonObject toJson() {
    //  JsonObject json = super.toJson();
    //  AmqpClientOptionsConverter.toJson(this, json);
    //  return json;
    //}

    /**
     * @return the host.
     */
    string getHost() {
        return host;
    }

    /**
     * Sets the host.
     *
     * @param host the host, must not be {@code null} when the client attempt to connect. Defaults to system variable
     *             {@code amqp-client-host} and to {@code AMQP_CLIENT_HOST} environment variable
     * @return the current {@link AmqpClientOptions}
     */
    AmqpClientOptions setHost(string host) {
        this.host = host;
        return this;
    }

    /**
     * @return the port.
     */
    int getPort() {
        return port;
    }

    /**
     * Sets the port.
     *
     * @param port the port, defaults to system variable {@code amqp-client-port} and to {@code AMQP_CLIENT_PORT}
     *             environment variable and if neither is set {@code 5672}.
     * @return the current {@link AmqpClientOptions}
     */
    AmqpClientOptions setPort(int port) {
        this.port = port;
        return this;
    }

    /**
     * @return the username
     */
    string getUsername() {
        return username;
    }

    /**
     * Sets the username.
     *
     * @param username the username, defaults to system variable {@code amqp-client-username} and
     *                 to {@code AMQP_CLIENT_USERNAME} environment variable.
     * @return the current {@link AmqpClientOptions}
     */
    AmqpClientOptions setUsername(string username) {
        this.username = username;
        return this;
    }

    /**
     * @return the password
     */
    string getPassword() {
        return password;
    }

    /**
     * Sets the password.
     *
     * @param pwd the password, defaults to system variable {@code amqp-client-password} and to
     *            {@code AMQP_CLIENT_PASSWORD} environment variable.
     * @return the current {@link AmqpClientOptions}
     */
    AmqpClientOptions setPassword(string pwd) {
        this.password = pwd;
        return this;
    }

    /**
     * @return the container id.
     */
    string getContainerId() {
        return containerId;
    }

    /**
     * Sets the container id.
     *
     * @param containerId the container id
     * @return the current {@link AmqpClientOptions}
     */
    AmqpClientOptions setContainerId(string containerId) {
        this.containerId = containerId;
        return this;
    }

    /**
     * @see ProtonClientOptions#addEnabledSaslMechanism(string)
     */
    override
    AmqpClientOptions addEnabledSaslMechanism(string saslMechanism) {
        super.addEnabledSaslMechanism(saslMechanism);
        return this;
    }

    /**
     * @see ProtonClientOptions#setSendBufferSize(int)
     */
    override
    AmqpClientOptions setSendBufferSize(int sendBufferSize) {
        super.setSendBufferSize(sendBufferSize);
        return this;
    }

    /**
     * @see ProtonClientOptions#setReceiveBufferSize(int)
     */
    override
    AmqpClientOptions setReceiveBufferSize(int receiveBufferSize) {
        super.setReceiveBufferSize(receiveBufferSize);
        return this;
    }

    /**
     * @see ProtonClientOptions#setReuseAddress(boolean)
     */
    override
    AmqpClientOptions setReuseAddress(bool reuseAddress) {
        super.setReuseAddress(reuseAddress);
        return this;
    }

    /**
     * @see ProtonClientOptions#setTrafficClass(int)
     */
    override
    AmqpClientOptions setTrafficClass(int trafficClass) {
        super.setTrafficClass(trafficClass);
        return this;
    }

    /**
     * @see ProtonClientOptions#setTcpNoDelay(boolean)
     */
    override
    AmqpClientOptions setTcpNoDelay(bool tcpNoDelay) {
        super.setTcpNoDelay(tcpNoDelay);
        return this;
    }

    /**
     * @see ProtonClientOptions#setTcpKeepAlive(boolean)
     */
    override
    AmqpClientOptions setTcpKeepAlive(bool tcpKeepAlive) {
        super.setTcpKeepAlive(tcpKeepAlive);
        return this;
    }

    /**
     * @see ProtonClientOptions#setSoLinger(int)
     */
    override
    AmqpClientOptions setSoLinger(int soLinger) {
        super.setSoLinger(soLinger);
        return this;
    }

    /**
     * @see ProtonClientOptions#setIdleTimeout(int)
     */
    override
    AmqpClientOptions setIdleTimeout(Duration idleTimeout) {
        super.setIdleTimeout(idleTimeout);
        return this;
    }

    /**
     * @see ProtonClientOptions#setSsl(boolean)
     */
    override
    AmqpClientOptions setSsl(bool ssl) {
        super.setSsl(ssl);
        return this;
    }

    /**
     * @see ProtonClientOptions#setKeyStoreOptions(JksOptions)
     */
    //override
    //AmqpClientOptions setKeyStoreOptions(JksOptions options) {
    //  super.setKeyStoreOptions(options);
    //  return this;
    //}

    /**
     * @see ProtonClientOptions#setPfxKeyCertOptions(PfxOptions)
     */
    //override
    //AmqpClientOptions setPfxKeyCertOptions(PfxOptions options) {
    //  super.setPfxKeyCertOptions(options);
    //  return this;
    //}

    /**
     * @see ProtonClientOptions#setPemKeyCertOptions(PemKeyCertOptions)
     */
    //override
    //AmqpClientOptions setPemKeyCertOptions(PemKeyCertOptions options) {
    //  super.setPemKeyCertOptions(options);
    //  return this;
    //}

    /**
     * @see ProtonClientOptions#setTrustStoreOptions(JksOptions)
     */
    //override
    //AmqpClientOptions setTrustStoreOptions(JksOptions options) {
    //  super.setTrustStoreOptions(options);
    //  return this;
    //}

    /**
     * @see ProtonClientOptions#setPemTrustOptions(PemTrustOptions)
     */
    //override
    //AmqpClientOptions setPemTrustOptions(PemTrustOptions options) {
    //  super.setPemTrustOptions(options);
    //  return this;
    //}

    /**
     * @see ProtonClientOptions#setPfxTrustOptions(PfxOptions)
     */
    //override
    //AmqpClientOptions setPfxTrustOptions(PfxOptions options) {
    //  super.setPfxTrustOptions(options);
    //  return this;
    //}

    /**
     * @see ProtonClientOptions#addEnabledCipherSuite(string)
     */
    //override
    //AmqpClientOptions addEnabledCipherSuite(string suite) {
    //  super.addEnabledCipherSuite(suite);
    //  return this;
    //}

    /**
     * @see ProtonClientOptions#addCrlPath(string)
     */
    //override
    //AmqpClientOptions addCrlPath(string crlPath) {
    //  super.addCrlPath(crlPath);
    //  return this;
    //}

    /**
     * @see ProtonClientOptions#addCrlValue(Buffer)
     */
    //override
    //AmqpClientOptions addCrlValue(Buffer crlValue) {
    //  super.addCrlValue(crlValue);
    //  return this;
    //}

    /**
     * @see ProtonClientOptions#setTrustAll(boolean)
     */
    override
    AmqpClientOptions setTrustAll(bool trustAll) {
        super.setTrustAll(trustAll);
        return this;
    }

    /**
     * @see ProtonClientOptions#setConnectTimeout(int)
     */
    override
    AmqpClientOptions setConnectTimeout(Duration connectTimeout) {
        super.setConnectTimeout(connectTimeout);
        return this;
    }

    /**
     * @see ProtonClientOptions#setReconnectAttempts(int)
     */
    override
    AmqpClientOptions setReconnectAttempts(int attempts) {
        super.setReconnectAttempts(attempts);
        return this;
    }

    /**
     * @see ProtonClientOptions#setReconnectInterval(long)
     */
    override
    AmqpClientOptions setReconnectInterval(Duration interval) {
        super.setReconnectInterval(interval);
        return this;
    }

    /**
     * @see ProtonClientOptions#addEnabledSecureTransportProtocol(string)
     */
    //override
    //AmqpClientOptions addEnabledSecureTransportProtocol(string protocol) {
    //  super.addEnabledSecureTransportProtocol(protocol);
    //  return this;
    //}

    /**
     * @see ProtonClientOptions#setHostnameVerificationAlgorithm(string)
     */
    override
    AmqpClientOptions setHostnameVerificationAlgorithm(string hostnameVerificationAlgorithm) {
        super.setHostnameVerificationAlgorithm(hostnameVerificationAlgorithm);
        return this;
    }

    /**
     * @see ProtonClientOptions#setJdkSslEngineOptions(JdkSSLEngineOptions)
     */
    //override
    //AmqpClientOptions setJdkSslEngineOptions(JdkSSLEngineOptions sslEngineOptions) {
    //  super.setJdkSslEngineOptions(sslEngineOptions);
    //  return this;
    //}

    /**
     * @see ProtonClientOptions#setOpenSslEngineOptions(OpenSSLEngineOptions)
     */
    //override
    //AmqpClientOptions setOpenSslEngineOptions(OpenSSLEngineOptions sslEngineOptions) {
    //  super.setOpenSslEngineOptions(sslEngineOptions);
    //  return this;
    //}

    /**
     * @see ProtonClientOptions#setSslEngineOptions(SSLEngineOptions)
     */
    //override
    //AmqpClientOptions setSslEngineOptions(SSLEngineOptions sslEngineOptions) {
    //  super.setSslEngineOptions(sslEngineOptions);
    //  return this;
    //}

    /**
     * @see ProtonClientOptions#setLocalAddress(string)
     */
    override
    AmqpClientOptions setLocalAddress(string localAddress) {
        super.setLocalAddress(localAddress);
        return this;
    }

    /**
     * @see ProtonClientOptions#setReusePort(boolean)
     */
    override
    AmqpClientOptions setReusePort(bool reusePort) {
        super.setReusePort(reusePort);
        return this;
    }

    /**
     * @see ProtonClientOptions#setTcpCork(boolean)
     */
    override
    AmqpClientOptions setTcpCork(bool tcpCork) {
        super.setTcpCork(tcpCork);
        return this;
    }

    /**
     * @see ProtonClientOptions#setTcpFastOpen(boolean)
     */
    override
    AmqpClientOptions setTcpFastOpen(bool tcpFastOpen) {
        super.setTcpFastOpen(tcpFastOpen);
        return this;
    }

    /**
     * @see ProtonClientOptions#setTcpQuickAck(boolean)
     */
    override
    AmqpClientOptions setTcpQuickAck(bool tcpQuickAck) {
        super.setTcpQuickAck(tcpQuickAck);
        return this;
    }

    /**
     * @see ProtonClientOptions#removeEnabledSecureTransportProtocol(string)
     */
    //override
    //AmqpClientOptions removeEnabledSecureTransportProtocol(string protocol) {
    //  super.removeEnabledSecureTransportProtocol(protocol);
    //  return this;
    //}

    /**
     * @see ProtonClientOptions#setEnabledSecureTransportProtocols(Set)
     */
    //override
    //AmqpClientOptions setEnabledSecureTransportProtocols(Set<string> enabledSecureTransportProtocols) {
    //  super.setEnabledSecureTransportProtocols(enabledSecureTransportProtocols);
    //  return this;
    //}

    /**
     * @see ProtonClientOptions#setVirtualHost(string)
     */
    override
    AmqpClientOptions setVirtualHost(string virtualHost) {
        super.setVirtualHost(virtualHost);
        return this;
    }

    /**
     * @see ProtonClientOptions#setSniServerName(string)
     */
    override
    AmqpClientOptions setSniServerName(string sniServerName) {
        super.setSniServerName(sniServerName);
        return this;
    }

    /**
     * @see ProtonClientOptions#setHeartbeat(int)
     */
    override
    AmqpClientOptions setHeartbeat(int heartbeat) {
        super.setHeartbeat(heartbeat);
        return this;
    }

    /**
     * @see ProtonClientOptions#setMaxFrameSize(int)
     */
    override
    AmqpClientOptions setMaxFrameSize(int maxFrameSize) {
        super.setMaxFrameSize(maxFrameSize);
        return this;
    }

    //private string getFromSysOrEnv(string key) {
    //  string sys = System.getProperty(key);
    //  if (sys is null) {
    //    return System.getenv(key.toUpperCase().replace("-", "_"));
    //  }
    //  return sys;
    //}
    //
    //private int getPortFromSysOrEnv() {
    //  string s = getFromSysOrEnv("amqp-client-port");
    //  if (s is null) {
    //    return 5672;
    //  } else {
    //    return Integer.parseInt(s);
    //  }
    //}
}
