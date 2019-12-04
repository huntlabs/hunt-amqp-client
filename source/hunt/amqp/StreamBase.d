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

module hunt.amqp.StreamBase;

import std.stdio;
import hunt.amqp.Handler;

interface StreamBase {
  StreamBase exceptionHandler(Handler!Throwable var1);
}

