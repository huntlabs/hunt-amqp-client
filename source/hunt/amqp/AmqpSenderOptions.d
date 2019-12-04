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
module hunt.amqp.AmqpSenderOptions;

//import hunt.codegen.annotations.DataObject;
//import hunt.core.json.JsonObject;

/**
 * Configures the AMQP Receiver.
 */
//@DataObject(generateConverter = true)
class AmqpSenderOptions {

  private string linkName;
  private bool dynamic;
  private bool autoDrained ;//= true;

  this() {
    autoDrained = true;
  }

  this(AmqpSenderOptions other) {
    this();
    setDynamic(other.isDynamic());
    setLinkName(other.getLinkName());
    setAutoDrained(other.isAutoDrained());
  }

  //public AmqpSenderOptions(JsonObject json) {
  //  super();
  //  AmqpSenderOptionsConverter.fromJson(json, this);
  //}

  //public JsonObject toJson() {
  //  JsonObject json = new JsonObject();
  //  AmqpSenderOptionsConverter.toJson(this, json);
  //  return json;
  //}

  public string getLinkName() {
    return linkName;
  }

  public AmqpSenderOptions setLinkName(string linkName) {
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
   * {@link AmqpSender#address()} method on the {@link AmqpSender} received once opened.
   *
   * @param dynamic true if the link should request a dynamic terminus address
   * @return the options
   */
  public AmqpSenderOptions setDynamic(bool dynamic) {
    this.dynamic = dynamic;
    return this;
  }

  /**
   * Get whether the link will automatically be marked drained after the send queue drain handler fires in drain mode.
   *
   * @return whether the link will automatically be drained after the send queue drain handler fires in drain mode
   * @see #setAutoDrained(bool)
   */
  public bool isAutoDrained() {
    return autoDrained;
  }

  /**
   * Sets whether the link is automatically marked drained after the send queue drain handler callback
   * returns if the receiving peer requested that credit be drained.
   * <p>
   * {@code true} by default.
   *
   * @param autoDrained whether the link will automatically be drained after the send queue drain handler fires in drain mode
   * @return the options
   */
  public AmqpSenderOptions setAutoDrained(bool autoDrained) {
    this.autoDrained = autoDrained;
    return this;
  }
}
