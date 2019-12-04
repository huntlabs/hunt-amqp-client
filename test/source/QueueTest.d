module QueueTest;

import std.stdio;
import hunt.amqp.AmqpClientOptions;
import hunt.amqp.AmqpClient;
import hunt.amqp.AmqpSender;
import hunt.amqp.AmqpMessage;
import hunt.amqp.Handler;
import hunt.amqp.AmqpReceiver;
import hunt.amqp.AmqpConnection;
import hunt.logging;
import core.thread;

void main()
{
  AmqpClientOptions options = new AmqpClientOptions()
  .setHost("127.0.0.1")
  .setPort(5672)
  .setUsername("guest")
  .setPassword("guest");

   AmqpClient client = AmqpClient.create(options);

   client.connect(new class Handler!AmqpConnection {
     void handle(AmqpConnection conn)
     {
        if (conn is null)
        {
          logWarning("Unable to connect to the broker");
          return;
        }

        logInfo("Connection succeeded");
        conn.createSender("my-queue",new class Handler!AmqpSender{
          void handle(AmqpSender sender)
          {
              if(sender is null)
              {
                logWarning("Unable to create a sender");
                return;
              }
              for (int i = 0 ; i < 10000000; ++i)
              {
                sender.send(AmqpMessage.create().withBody("hello -----------------------------------------！@@￥#￥%……%￥……%&（*&（").build());
                logInfo("send complite");
                 Thread.sleep(500.msecs);
              }
          }
        });

       conn.createReceiver("my-queue", new class Handler!AmqpReceiver {
          void handle(AmqpReceiver recv)
          {
              if(recv is null)
              {
                logWarning("Unable to create a receiver");
                return;
              }
              recv.handler(new class Handler!AmqpMessage {
                void handle(AmqpMessage msg){
                  logInfo("Received %s" , msg.bodyAsString());
                }
              });
          }
       });
     }
   });
}

