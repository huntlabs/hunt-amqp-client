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
module hunt.amqp.client.impl.AmqpMessageImpl;

import hunt.proton.amqp.messaging.Section;
import hunt.amqp.client.AmqpMessage;
import hunt.amqp.ProtonDelivery;
import hunt.amqp.ProtonHelper;
import hunt.proton.amqp.Symbol;
import hunt.proton.message.Message;
import hunt.proton.amqp.messaging.AmqpValue;
import hunt.proton.amqp.messaging.AmqpSequence;
import hunt.proton.amqp.messaging.Data;
import hunt.proton.amqp.messaging.ApplicationProperties;
import hunt.Exceptions;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.Boolean;
import hunt.Short;
import hunt.Byte;
import hunt.Long;
import hunt.Float;
import hunt.Char;
import hunt.Double;
import hunt.Integer;
import hunt.String;

//import hunt.collection.UUID;

class AmqpMessageImpl : AmqpMessage {
  private  Message message;
  private  ProtonDelivery delivery;

  this(Message message, ProtonDelivery delivery) {
    this.message = message;
    this.delivery = delivery;
  }

  this(Message message) {
    this.message = message;
    this.delivery = null;
  }


  public bool isDurable() {
    return message.isDurable();
  }


  public bool isFirstAcquirer() {
    return message.isFirstAcquirer();
  }


  public int priority() {
    return message.getPriority();
  }


  public string id() {
    Object id = message.getMessageId();
    if (id !is null) {
      return (cast(String)id).value;
    }
    return null;
  }


  public string address() {
    //return message.getAddress().value;
   return message.getAddress() is null ? null :message.getAddress().value;
  }


  public string replyTo() {
    return message.getReplyTo().value;
  }


  public string correlationId() {
    Object id = message.getCorrelationId();
    if (id !is null) {
      return (cast(String)id).value;
    }
    return null;
  }


  public bool isBodyNull() {
    return message.getBody() is null || getAmqpValue() is null;
  }

  private Object getAmqpValue() {
    if (message.getBody().getType() != Section.SectionType.AmqpValue) {
      throw new IllegalStateException("The body is not an AMQP Value");
    }
    return (cast(AmqpValue) message.getBody()).getValue();
  }


  public bool bodyAsBoolean() {
    return (cast(Boolean) getAmqpValue()).booleanValue;
  }


  public byte bodyAsByte() {
    return (cast(Byte) getAmqpValue()).byteValue;
  }


  public short bodyAsShort() {
    return (cast(Short) getAmqpValue()).shortValue;
  }


  public int bodyAsInteger() {
    return (cast(Integer) getAmqpValue()).intValue;
  }


  public long bodyAsLong() {
    return (cast(Long) getAmqpValue()).longValue;
  }


  public float bodyAsFloat() {
    return (cast(Float) getAmqpValue()).floatValue;
  }


  public double bodyAsDouble() {
    return (cast(Double) getAmqpValue()).doubleValue;
  }


  public char bodyAsChar() {
    return (cast(Char) getAmqpValue()).value;
  }


  //public Instant bodyAsTimestamp() {
  //  Object value = getAmqpValue();
  //  if (!(value instanceof Date)) {
  //    throw new IllegalStateException("Expecting a Date object, got a " + value);
  //  }
  //  return ((Date) value).toInstant();
  //}
  //
  //
  //public UUID bodyAsUUID() {
  //  return (UUID) getAmqpValue();
  //}


  public byte[] bodyAsBinary() {
    Section bd = message.getBody();
    if (bd.getType() != Section.SectionType.Data) {
      throw new IllegalStateException("The body is not of type 'data'");
    }
    byte[] bytes = (cast(Data) message.getBody()).getValue().getArray();
   // return Buffer.buffer(bytes);
    return bytes;
  }


  public string bodyAsString() {
    return (cast(String) getAmqpValue()).value;
  }


  public string bodyAsSymbol() {
    Object value = getAmqpValue();
    if (cast(Symbol)value !is null) {
      return (cast(Symbol) value).toString();
    }
    throw new IllegalStateException("Expected a Symbol, got a ");
  }

  /**
   * @noinspection unchecked
   */

  public List!Object bodyAsList() {
    Section bd = message.getBody();
    if (bd.getType() == Section.SectionType.AmqpSequence) {
      return (cast(AmqpSequence) message.getBody()).getValue();
    } else {
      //Object value = getAmqpValue();
      //if (value instanceof List) {
      //  return (List<T>) value;
      //}
      throw new IllegalStateException("Cannot extract a list from the message body");
    }
  }

  /**
   * @noinspection unchecked
   */

  //public <K, V> Map<K, V> bodyAsMap() {
  //  Object value = getAmqpValue();
  //  if (value instanceof Map) {
  //    return (Map<K, V>) value;
  //  }
  //  throw new IllegalStateException("Cannot extract a map from the message body");
  //}


  //public JsonObject bodyAsJsonObject() {
  //  return bodyAsBinary().toJsonObject();
  //}


  //public JsonArray bodyAsJsonArray() {
  //  return bodyAsBinary().toJsonArray();
  //}


  public string subject() {
    return message.getSubject().value;
  }


  public string contentType() {
    return message.getContentType().value;
  }


  public string contentEncoding() {
    return message.getContentEncoding().value;
  }


  public long expiryTime() {
    return message.getExpiryTime();
  }


  public long creationTime() {
    return message.getCreationTime();
  }


  public long ttl() {
    return message.getTtl();
  }


  public int deliveryCount() {
    return cast(int) message.getDeliveryCount();
  }


  public string groupId() {
    return message.getGroupId().value;
  }


  public string replyToGroupId() {
    return message.getReplyToGroupId().value;
  }


  public long groupSequence() {
    return message.getGroupSequence();
  }


  public ApplicationProperties applicationProperties() {
    ApplicationProperties properties = message.getApplicationProperties();
    if (properties is null) {
      return null;
    }
  //  return JsonObject.mapFrom(properties.getValue());
    return properties;
  }


  public Message unwrap() {
    return message;
  }


  public AmqpMessage accepted() {
    if (delivery !is null) {
      ProtonHelper.accepted(delivery, true);
    } else {
      throw new IllegalStateException("The message is not a received message");
    }
    return this;
  }


  public AmqpMessage rejected() {
    if (delivery !is null) {
      ProtonHelper.rejected(delivery, true);
    } else {
      throw new IllegalStateException("The message is not a received message");
    }
    return this;
  }


  public AmqpMessage released() {
    if (delivery !is null) {
      ProtonHelper.released(delivery, true);
    } else {
      throw new IllegalStateException("The message is not a received message");
    }
    return this;
  }


  public AmqpMessage modified(bool didItFail, bool wasItDeliveredHere) {
    if (delivery !is null) {
      ProtonHelper.modified(delivery, true, didItFail, wasItDeliveredHere);
    } else {
      throw new IllegalStateException("The message is not a received message");
    }
    return this;
  }
}
