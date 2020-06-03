module sender;

import hunt.amqp.client.AmqpClientOptions;
import hunt.amqp.client.AmqpClient;
import hunt.amqp.client.AmqpSender;
import hunt.amqp.client.AmqpMessage;
import hunt.amqp.client.AmqpPool;
import hunt.amqp.Handler;
import hunt.amqp.client.AmqpReceiver;
import hunt.amqp.client.AmqpConnection;

import hunt.logging.ConsoleLogger;
import hunt.Object;

import core.thread;
import core.time;

import std.conv;
import std.datetime;
import std.format;
import std.parallelism;
import std.stdio;

enum Total = 1;

void main(string[] agrs) {

    int number = Total;

    if(agrs.length >=2) {
        number = to!int(agrs[1]);
        if(number <=0 ) number = Total;
    }

    AmqpClientOptions options = new AmqpClientOptions().setHost("10.1.222.110")
        .setPort(5672).setUsername("admin").setPassword("admin");

    // AmqpClientOptions options = new AmqpClientOptions().setHost("10.1.223.62")
    //     .setPort(5672).setUsername("test").setPassword("123");

    // AmqpClientOptions options = new AmqpClientOptions().setHost("121.40.16.40")
    //     .setPort(5672).setUsername("admin").setPassword("RzNKT565Twof");    

    // AmqpPool pool = new AmqpPool(options);
    // AmqpConnection conn = pool.borrowObject();

    AmqpClient client = AmqpClient.create(options);
    AmqpConnection conn = client.connect();

    if (conn is null) {
        logWarning("Unable to connect to the broker");
        return;
    }

    logInfo("Connection succeeded");
    // dfmt off
    conn.createSender("my-queue", new class Handler!AmqpSender {
        void handle(AmqpSender sender) {
            if(sender is null) {
                logWarning("Unable to create a sender");
                return;
            }

			foreach(index; 0..number) {
				DateTime dt = cast(DateTime)Clock.currTime();
				string message = format("[%d] Say hello at %s", index, dt.toSimpleString());
                AmqpMessage amqpMessage = AmqpMessage.create().withBody(message).build();
				sender.send(amqpMessage);
				tracef("Message %d sent. The content is: '%s'", index, message);
				// Thread.sleep(1.seconds);
			}

			trace("All message sent.");
            // pool.returnObject(conn);

            // FIXME: Needing refactor or cleanup -@zhangxueping at 2020-03-27T17:24:05+08:00
            // more tests
            // sender.end(new class Handler!Void {
            //     void handle(Void v) {
            //         warning("Sender ended.");
            //     }
            // });

            sender.close(new class Handler!Void {
                void handle(Void v) {
                    warning("Sender closed.");
                }
            });

            // conn.close(new class Handler!Void {
            //     void handle(Void v) {
            //         warning("Connection closed.");
            //     }
            // });
        }
    });
    // dfmt on

    // pool.returnObject(conn);

    warning("Done.");
}
