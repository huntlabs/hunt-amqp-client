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
module hunt.amqp.AmqpReceiverOptions;

//import hunt.codegen.annotations.DataObject;
//import hunt.core.json.JsonObject;

import hunt.collection.ArrayList;
import hunt.collection.List;
import hunt.Object;

/**
 * Configures the AMQP Receiver.
 */
//@DataObject(generateConverter = true)
class AmqpReceiverOptions {

  private string linkName;
  private bool dynamic;
  private string qos;
  private List!string capabilities ;// = new ArrayList<>();
  private bool durable;
  private int maxBufferedMessages;
  private bool autoAcknowledgement ;// = true;

  this() {
    capabilities = new ArrayList!string;
    autoAcknowledgement = true;
  }

  this(AmqpReceiverOptions other) {
    this();
    setDynamic(other.isDynamic());
    setLinkName(other.getLinkName());
    setCapabilities(other.getCapabilities());
    setDurable(other.isDurable());
    setMaxBufferedMessages(other.maxBufferedMessages);
  }

  //public AmqpReceiverOptions(JsonObject json) {
  //  super();
  //  AmqpReceiverOptionsConverter.fromJson(json, this);
  //}
  //
  //public JsonObject toJson() {
  //  JsonObject json = new JsonObject();
  //  AmqpReceiverOptionsConverter.toJson(this, json);
  //  return json;
  //}

  public string getLinkName() {
    return linkName;
  }

  public AmqpReceiverOptions setLinkName(string linkName) {
    this.linkName = linkName;
    return this;
  }

  /**
   * @return whether the receiver is using a dynamic address.
   */
  public bool isDynamic() {
    return dynamic;
  }

  /**
   * Sets whether the link remote terminus to be used should indicate it is
   * 'dynamic', requesting the peer names it with a dynamic address.
   * <p>
   * The address provided by the peer can then be inspected using the
   * {@link AmqpReceiver#address()} method on the {@link AmqpReceiver} received once opened.
   *
   * @param dynamic true if the link should request a dynamic terminus address
   * @return the options
   */
  public AmqpReceiverOptions setDynamic(bool dynamic) {
    this.dynamic = dynamic;
    return this;
  }

  /**
   * Gets the local QOS config, values can be {@code null}, {@code AT_MOST_ONCE} or {@code AT_LEAST_ONCE}.
   *
   * @return the local QOS config.
   */
  public string getQos() {
    return qos;
  }

  /**
   * Sets the local QOS config.
   *
   * @param qos the local QOS config. Accepted values are: {@code null}, {@code AT_MOST_ONCE} or {@code AT_LEAST_ONCE}.
   * @return the options.
   */
  public AmqpReceiverOptions setQos(string qos) {
    this.qos = qos;
    return this;
  }

  /**
   * Gets the list of desired capabilities for the source.
   * A registry of commonly defined source capabilities and their meanings is maintained at
   * <a href="http://www.amqp.org/specification/1.0/source-capabilities">AMQP Source Capabilities</a>.
   *
   * @return the list of capabilities, empty if none.
   */
  public List!string getCapabilities() {
    if (capabilities is null) {
      return new ArrayList!string();
    }
    return capabilities;
  }

  /**
   * Sets the list of desired capabilities
   * A registry of commonly defined source capabilities and their meanings is maintained at
   * <a href="http://www.amqp.org/specification/1.0/source-capabilities">AMQP Source Capabilities</a>.
   *
   * @param capabilities the set of capabilities.
   * @return the options
   */
  public AmqpReceiverOptions setCapabilities(List!string capabilities) {
    this.capabilities = capabilities;
    return this;
  }

  /**
   * Adds a desired capability.
   * A registry of commonly defined source capabilities and their meanings is maintained at
   * <a href="http://www.amqp.org/specification/1.0/source-capabilities">AMQP Source Capabilities</a>.
   *
   * @param capability the capability to add, must not be {@code null}
   * @return the options
   */
  public AmqpReceiverOptions addCapability(string capability) {
  //  Objects.requireNonNull(capability, "The capability must not be null");
    if (this.capabilities is null) {
      this.capabilities = new ArrayList!string();
    }
    this.capabilities.add(capability);
    return this;
  }

  /**
   * @return if the receiver is durable.
   */
  public bool isDurable() {
    return durable;
  }

  /**
   * Sets the durability.
   * <p>
   * Passing {@code true} sets the expiry policy of the source to {@code NEVER} and the durability of the source
   * to {@code UNSETTLED_STATE}.
   *
   * @param durable whether or not the receiver must indicate it's durable
   * @return the options.
   */
  public AmqpReceiverOptions setDurable(bool durable) {
    this.durable = durable;
    return this;
  }

  /**
   * @return the max buffered messages
   */
  public int getMaxBufferedMessages() {
    return this.maxBufferedMessages;
  }

  /**
   * Sets the max buffered messages. This message can be used to configure the initial credit of a receiver.
   *
   * @param maxBufferSize the max buffered size, must be positive. If not set, default credit is used.
   * @return the current {@link AmqpReceiverOptions} instance.
   */
  public AmqpReceiverOptions setMaxBufferedMessages(int maxBufferSize) {
    this.maxBufferedMessages = maxBufferSize;
    return this;
  }

  /**
   * @return {@code true} if the auto-acknowledgement is enabled, {@code false} otherwise.
   */
  public bool isAutoAcknowledgement() {
    return autoAcknowledgement;
  }

  /**
   * Sets the auto-acknowledgement.
   * When enabled (default), the messages are automatically acknowledged. If set to {@code false}, the messages must
   * be acknowledged explicitly using {@link AmqpMessage#accepted()}, {@link AmqpMessage#released()} and
   * {@link AmqpMessage#rejected()}.
   *
   * @param auto whether or not the auto-acknowledgement should be enabled.
   * @return the current {@link AmqpReceiverOptions} instance.
   */
  public AmqpReceiverOptions setAutoAcknowledgement(bool aut) {
    this.autoAcknowledgement = aut;
    return this;
  }
}
