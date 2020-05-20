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
module hunt.amqp.client.AmqpMessage;

import hunt.amqp.client.impl.AmqpMessageBuilderImpl;
import hunt.proton.message.Message;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.amqp.client.AmqpMessageBuilder;
import std.json;

/**
 * Represents an AMQP message.
 * <p>
 * Reference about the different metadata can be found on
 * <a href="http://docs.oasis-open.org/amqp/core/v1.0/amqp-core-messaging-v1.0.html#type-properties">AMQP message properties</a>.
 * <p>
 * Note that the body is retrieved using {@code body*} method depending on the expected type.
 */
interface AmqpMessage {

  /**
   * @return a builder to create an {@link AmqpMessage}.
   */
  static AmqpMessageBuilder create() {
    return new AmqpMessageBuilderImpl();
  }

  /**
   * Creates a builder to create a new {@link AmqpMessage} copying the metadata from the passed message.
   *
   * @param existing an existing message, must not be {@code null}.
   * @return a builder to create an {@link AmqpMessage}.
   */
  static AmqpMessageBuilder create(AmqpMessage existing) {
    return new AmqpMessageBuilderImpl(existing);
  }

  /**
   * Creates a builder to create a new {@link AmqpMessage} copying the metadata from the passed (Proton) message.
   *
   * @param existing an existing (Proton) message, must not be {@code null}.
   * @return a builder to create an {@link AmqpMessage}.
   */
 // @GenIgnore
  static AmqpMessageBuilder create(Message existing) {
    return new AmqpMessageBuilderImpl(existing);
  }

  /**
   * @return whether or not the message is durable.
   * @see <a href="http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-messaging-v1.0-os.html#type-header">AMQP specification</a>
   */
  bool isDurable();

  /**
   * @return if {@code true}, then this message has not been acquired by any other link. If {@code false}, then this
   * message MAY have previously been acquired by another link or links.
   * @see <a href="http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-messaging-v1.0-os.html#type-header">AMQP specification</a>
   */
  bool isFirstAcquirer();

  /**
   * @return the relative message priority. Higher numbers indicate higher priority messages. Messages with higher
   * priorities MAY be delivered before those with lower priorities.
   * @see <a href="http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-messaging-v1.0-os.html#type-header">AMQP specification</a>
   */
  int priority();

  /**
   * @return the number of unsuccessful previous attempts to deliver this message. If this value is non-zero it can be
   * taken as an indication that the delivery might be a duplicate. On first delivery, the value is zero. It is
   * incremented upon an outcome being settled at the sender, according to rules defined for each outcome.
   * @see <a href="http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-messaging-v1.0-os.html#type-header">AMQP specification</a>
   */
  int deliveryCount();

  /**
   * @return the duration in milliseconds for which the message is to be considered "live".
   * @see <a href="http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-messaging-v1.0-os.html#type-properties">AMQP specification</a>
   */
  long ttl();

  /**
   * @return the message id
   * @see <a href="http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-messaging-v1.0-os.html#type-properties">AMQP specification</a>
   */
  string id();

  /**
   * @return the message address, also named {@code to} field
   * @see <a href="http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-messaging-v1.0-os.html#type-properties">AMQP specification</a>
   */
  string address();

  /**
   * @return The address of the node to send replies to, if any.
   * @see <a href="http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-messaging-v1.0-os.html#type-properties">AMQP specification</a>
   */
  string replyTo();

  /**
   * @return The client-specific id that can be used to mark or identify messages between clients.
   * @see <a href="http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-messaging-v1.0-os.html#type-properties">AMQP specification</a>
   */
  string correlationId();

  /**
   * @return whether the body is {@code null}. This method returns {@code true} is the message does not contain a body or
   * if the message contain a {@code null} AMQP value as body.
   */
  bool isBodyNull();

  /**
   * @return the boolean value contained in the body. The value must be passed as AMQP value.
   */
  bool bodyAsBoolean();

  /**
   * @return the byte value contained in the body. The value must be passed as AMQP value.
   */
  byte bodyAsByte();

  /**
   * @return the short value contained in the body. The value must be passed as AMQP value.
   */
  short bodyAsShort();

  /**
   * @return the integer value contained in the body. The value must be passed as AMQP value.
   */
  int bodyAsInteger();

  /**
   * @return the long value contained in the body. The value must be passed as AMQP value.
   */
  long bodyAsLong();

  /**
   * @return the float value contained in the body. The value must be passed as AMQP value.
   */
  float bodyAsFloat();

  /**
   * @return the double value contained in the body. The value must be passed as AMQP value.
   */
  double bodyAsDouble();

  /**
   * @return the character value contained in the body. The value must be passed as AMQP value.
   */
  char bodyAsChar();

  /**
   * @return the timestamp value contained in the body. The value must be passed as AMQP value.
   */
  //@GenIgnore(GenIgnore.PERMITTED_TYPE)
  //Instant bodyAsTimestamp();

  /**
   * @return the UUID value contained in the body. The value must be passed as AMQP value.
   */
  //@GenIgnore(GenIgnore.PERMITTED_TYPE)
  //UUID bodyAsUUID();

  /**
   * @return the bytes contained in the body. The value must be passed as AMQP data.
   */
  byte[] bodyAsBinary();

  /**
   * @return the string value contained in the body. The value must be passed as AMQP value.
   */
  string bodyAsString();

  /**
   * @return the symbol value contained in the body. The value must be passed as AMQP value.
   */
  string bodyAsSymbol();

  /**
   * @return the list of values contained in the body. The value must be passed as AMQP value.
   */
  List!Object bodyAsList();

  /**
   * @return the map contained in the body. The value must be passed as AMQP value.
   */
  //@GenIgnore
  //<K, V> Map<K, V> bodyAsMap();

  /**
   * @return the JSON object contained in the body. The value must be passed as AMQP data.
   */
  //JsonObject bodyAsJsonObject();

  /**
   * @return the JSON array contained in the body. The value must be passed as AMQP data.
   */
  //JsonArray bodyAsJsonArray();

  string subject();

  string contentType();

  string contentEncoding();

  long expiryTime();

  long creationTime();

  string groupId();

  string replyToGroupId();

  long groupSequence();

  /**
   * @return the message properties as JSON object.
   */
 // JSONValue applicationProperties();

 // @GenIgnore
  Message unwrap();

  /**
   * When receiving a message, and when auto-acknowledgement is disabled, this method is used to acknowledge
   * the incoming message. It marks the message as delivered with the {@code accepted} status.
   *
   * @return the current {@link AmqpMessage} object
   * @throws IllegalStateException is the current message is not a received message.
   */
  AmqpMessage accepted();

  /**
   * When receiving a message, and when auto-acknowledgement is disabled, this method is used to acknowledge
   * the incoming message as {@code rejected}.
   *
   * @return the current {@link AmqpMessage} object
   * @throws IllegalStateException is the current message is not a received message.
   */
  AmqpMessage rejected();

  /**
   * When receiving a message, and when auto-acknowledgement is disabled, this method is used to acknowledge
   * the incoming message as {@code released}.
   *
   * @return the current {@link AmqpMessage} object
   * @throws IllegalStateException is the current message is not a received message.
   */
  AmqpMessage released();

  /**
   * When receiving a message,  and when auto-acknowledgement is disabled, this method is used to acknowledge
   * the incoming message as {@code modified}.
   *
   * @param didItFail          pass {@code true} to increase the failed delivery count
   * @param wasItDeliveredHere pass {@code true} to prevent the re-delivery of the message
   * @return the current {@link AmqpMessage} object
   * @throws IllegalStateException is the current message is not a received message.
   */
  AmqpMessage modified(bool didItFail, bool wasItDeliveredHere);


  //TODO What type should we use for delivery annotations and message annotations

}
