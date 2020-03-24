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
module hunt.amqp.client.AmqpMessageBuilder;

import hunt.amqp.client.impl.AmqpMessageBuilderImpl;
import hunt.amqp.client.AmqpMessage;
//import hunt.codegen.annotations.GenIgnore;
//import hunt.codegen.annotations.VertxGen;
//import hunt.core.buffer.Buffer;
//import hunt.core.json.JsonArray;
//import hunt.core.json.JsonObject;

//import java.time.Instant;
import hunt.collection.List;
import hunt.collection.Map;
//import hunt.collection.UUID;

/**
 * Builder to create a new {@link AmqpMessage}.
 * <p>
 * Reference about the different metadata can be found on
 * <a href="http://docs.oasis-open.org/amqp/core/v1.0/amqp-core-messaging-v1.0.html#type-properties">AMQP message properties</a>.
 * <p>
 * Note that the body is set using {@code withBodyAs*} method depending on the passed type.
 */
//@VertxGen
interface AmqpMessageBuilder {

  /**
   * @return a new instance of {@link AmqpMessageBuilder}
   */
  static AmqpMessageBuilder create() {
    return new AmqpMessageBuilderImpl();
  }

  /**
   * @return the message.
   */
  AmqpMessage build();

  // Headers

  AmqpMessageBuilder priority(short priority);

  AmqpMessageBuilder durable(bool durable);

  AmqpMessageBuilder ttl(long ttl);

  AmqpMessageBuilder firstAcquirer(bool first);

  AmqpMessageBuilder deliveryCount(int count);

  // Properties

  AmqpMessageBuilder id(string id);

  AmqpMessageBuilder address(string address);

  AmqpMessageBuilder replyTo(string replyTo);

  AmqpMessageBuilder correlationId(string correlationId);

  AmqpMessageBuilder withBody(string value);

  AmqpMessageBuilder withSymbolAsBody(string value);

  AmqpMessageBuilder subject(string subject);

  AmqpMessageBuilder contentType(string ct);

  AmqpMessageBuilder contentEncoding(string ct);

  AmqpMessageBuilder expiryTime(long expiry);

  AmqpMessageBuilder creationTime(long ct);

  AmqpMessageBuilder groupId(string gi);

  AmqpMessageBuilder replyToGroupId(string rt);

  //AmqpMessageBuilder applicationProperties(JsonObject props);

  AmqpMessageBuilder withBooleanAsBody(bool v);

  AmqpMessageBuilder withByteAsBody(byte v);

  AmqpMessageBuilder withShortAsBody(short v);

  AmqpMessageBuilder withIntegerAsBody(int v);

  AmqpMessageBuilder withLongAsBody(long v);

  AmqpMessageBuilder withFloatAsBody(float v);

  AmqpMessageBuilder withDoubleAsBody(double v);

  AmqpMessageBuilder withCharAsBody(char c);

 // @GenIgnore(GenIgnore.PERMITTED_TYPE)
 // AmqpMessageBuilder withInstantAsBody(Instant v);

//  @GenIgnore(GenIgnore.PERMITTED_TYPE)
//  AmqpMessageBuilder withUuidAsBody(UUID v);
////
// // @GenIgnore
//  AmqpMessageBuilder withListAsBody(List list);
//
////  @GenIgnore
//  AmqpMessageBuilder withMapAsBody(Map map);

  //AmqpMessageBuilder withBufferAsBody(Buffer buffer);
  //
  //AmqpMessageBuilder withJsonObjectAsBody(JsonObject json);
  //
  //AmqpMessageBuilder withJsonArrayAsBody(JsonArray json);
}
