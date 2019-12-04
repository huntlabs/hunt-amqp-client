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
module hunt.amqp.impl.AmqpMessageBuilderImpl;

import hunt.amqp.AmqpMessage;
import hunt.amqp.AmqpMessageBuilder;
import hunt.amqp.impl.AmqpMessageImpl;

//import hunt.core.buffer.Buffer;
//import hunt.core.json.JsonArray;
//import hunt.core.json.JsonObject;
import hunt.proton.amqp.Binary;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.messaging.AmqpValue;
import hunt.proton.amqp.messaging.ApplicationProperties;
import hunt.proton.amqp.messaging.Data;
import hunt.proton.message.Message;
import hunt.Exceptions;
import hunt.String;
//import java.sql.Date;
//import java.time.Instant;
import hunt.collection.List;
import hunt.collection.Map;
//import hunt.collection.UUID;

class AmqpMessageBuilderImpl : AmqpMessageBuilder {

  private Message message;

  this() {
    message = Message.Factory.create();
  }

  this(AmqpMessage existing) {
    message = existing.unwrap();
  }

  this(Message existing) {
    message = existing;
  }


  public AmqpMessage build() {
    return new AmqpMessageImpl(message);
  }


  public AmqpMessageBuilderImpl priority(short priority) {
    message.setPriority(priority);
    return this;
  }

   public AmqpMessageBuilder durable(bool durable) {
    message.setDurable(durable);
    return this;
  }


  public AmqpMessageBuilderImpl id(string id) {
    message.setMessageId(new String(id));
    return this;
  }


  public AmqpMessageBuilderImpl address(string address) {
    message.setAddress(new String(address));
    return this;
  }


  public AmqpMessageBuilderImpl replyTo(string replyTo) {
    message.setReplyTo(new String(replyTo));
    return this;
  }


  public AmqpMessageBuilderImpl correlationId(string correlationId) {
    message.setCorrelationId(new String(correlationId));
    return this;
  }


  public AmqpMessageBuilderImpl withBody(string value) {
    message.setBody(new AmqpValue(new String(value)));
    return this;
  }


  public AmqpMessageBuilderImpl withSymbolAsBody(string value) {
    implementationMissing(false);
   // message.setBody(new AmqpValue(Symbol.valueOf(value)));
    return this;
  }


  public AmqpMessageBuilderImpl subject(string subject) {
    message.setSubject(new String(subject));
    return this;
  }


  public AmqpMessageBuilderImpl contentType(string ct) {
    message.setContentType(new String(ct));
    return this;
  }


  public AmqpMessageBuilderImpl contentEncoding(string ct) {
    message.setContentEncoding(new String(ct));
    return this;
  }


  public AmqpMessageBuilderImpl expiryTime(long expiry) {
    message.setExpiryTime(expiry);
    return this;
  }


  public AmqpMessageBuilderImpl creationTime(long ct) {
    message.setCreationTime(ct);
    return this;
  }


  public AmqpMessageBuilderImpl ttl(long ttl) {
    message.setTtl(ttl);
    return this;
  }

   public AmqpMessageBuilder firstAcquirer(bool first) {
    message.setFirstAcquirer(first);
    return this;
  }

   public AmqpMessageBuilder deliveryCount(int count) {
    message.setDeliveryCount(count);
    return this;
  }


  public AmqpMessageBuilderImpl groupId(string gi) {
    message.setGroupId(new String(gi));
    return this;
  }


  public AmqpMessageBuilderImpl replyToGroupId(string rt) {
    message.setReplyToGroupId(new String(rt));
    return this;
  }


  //public AmqpMessageBuilderImpl applicationProperties(JsonObject props) {
  //  ApplicationProperties properties = new ApplicationProperties(props.getMap());
  //  message.setApplicationProperties(properties);
  //  return this;
  //}


  public AmqpMessageBuilderImpl withBooleanAsBody(bool v) {
    implementationMissing(false);
  //  message.setBody(new AmqpValue(v));
    return this;
  }


  public AmqpMessageBuilderImpl withByteAsBody(byte v) {
    implementationMissing(false);
    //message.setBody(new AmqpValue(v));
    return this;
  }


  public AmqpMessageBuilderImpl withShortAsBody(short v) {
    implementationMissing(false);
    //message.setBody(new AmqpValue(v));
    return this;
  }


  public AmqpMessageBuilderImpl withIntegerAsBody(int v) {
    implementationMissing(false);
   // message.setBody(new AmqpValue(v));
    return this;
  }


  public AmqpMessageBuilderImpl withLongAsBody(long v) {
    implementationMissing(false);
    // message.setBody(new AmqpValue(v));
    return this;
  }


  public AmqpMessageBuilderImpl withFloatAsBody(float v) {
    implementationMissing(false);
    //message.setBody(new AmqpValue(v));
    return this;
  }


  public AmqpMessageBuilderImpl withDoubleAsBody(double v) {
    implementationMissing(false);
    //message.setBody(new AmqpValue(v));
    return this;
  }


  public AmqpMessageBuilderImpl withCharAsBody(char c) {
    implementationMissing(false);
    //message.setBody(new AmqpValue(c));
    return this;
  }


 // @GenIgnore(GenIgnore.PERMITTED_TYPE)
 // public AmqpMessageBuilderImpl withInstantAsBody(Instant v) {
 //   implementationMissing(false);
 //   //message.setBody(new AmqpValue(Date.from(v)));
 //   return this;
 // }


  //@GenIgnore(GenIgnore.PERMITTED_TYPE)
  //public AmqpMessageBuilderImpl withUuidAsBody(UUID v) {
  //  message.setBody(new AmqpValue(v));
  //  return this;
  //}


  //public AmqpMessageBuilderImpl withListAsBody(List list) {
  //  message.setBody(new AmqpValue(list));
  //  return this;
  //}


  //@GenIgnore(GenIgnore.PERMITTED_TYPE)
  //public AmqpMessageBuilderImpl withMapAsBody(Map map) {
  //  message.setBody(new AmqpValue(map));
  //  return this;
  //}


  //public AmqpMessageBuilderImpl withBufferAsBody(Buffer buffer) {
  //  message.setBody(new Data(new Binary(buffer.getBytes())));
  //  return this;
  //}


  //public AmqpMessageBuilderImpl withJsonObjectAsBody(JsonObject json) {
  //  return contentType("application/json")
  //    .withBufferAsBody(json.toBuffer());
  //}


  //public AmqpMessageBuilderImpl withJsonArrayAsBody(JsonArray json) {
  //  return contentType("application/json")
  //    .withBufferAsBody(json.toBuffer());
  //}
}
