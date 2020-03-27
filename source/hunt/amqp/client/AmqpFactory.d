module hunt.amqp.client.AmqpFactory;

import hunt.amqp.client.AmqpClientOptions;
import hunt.amqp.client.AmqpConnection;
import hunt.amqp.client.impl.AmqpClientImpl;
import hunt.amqp.client.impl.AmqpConnectionImpl;
import hunt.amqp.Handler;
import hunt.amqp.ProtonClient;

import hunt.pool.PooledObject;
import hunt.pool.PooledObjectFactory;
import hunt.pool.impl.DefaultPooledObject;

import hunt.concurrency.FuturePromise;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.net.util.HttpURI;

import std.format;
import std.string;

/**
 * PoolableObjectFactory custom impl.
 */
class AmqpFactory : PooledObjectFactory!(AmqpConnection) {
    private AmqpClientOptions _options;
    private ProtonClient _proton;

    this(AmqpClientOptions options) {
        _options = options;
        _proton = ProtonClient.create();
    }

    void activateObject(IPooledObject obj) {
        version (HUNT_AMQP_DEBUG)
            warning("Do nothing.");
    }

    void destroyObject(IPooledObject obj) {
        auto pooledObj = cast(PooledObject!(AmqpConnection))obj;
        AmqpConnection conn = pooledObj.getObject();
        if (conn !is null)
            conn.close(null);
    }

    IPooledObject makeObject() {
        // dfmt off
        auto promise = new FuturePromise!AmqpConnection();

        AmqpConnectionImpl conn = new AmqpConnectionImpl(null, _options, _proton, 
            new class Handler!AmqpConnection {
                void handle(AmqpConnection conn) {
                    if (conn is null) 
                        promise.failed(new Exception("Unable to connect to the broker."));
                    else
                        promise.succeeded(conn);
                }
            }
        );
        // dfmt on

        version (HUNT_AMQP_DEBUG) tracef("try to get a result in %s", _options.getIdleTimeout());
        AmqpConnection c = promise.get(_options.getIdleTimeout());
        return new DefaultPooledObject!(AmqpConnection)(c);
    }

    void passivateObject(IPooledObject obj) {
        implementationMissing(false);
    }

    bool validateObject(IPooledObject obj) {
        version (HUNT_AMQP_DEBUG)
            warning("Do nothing.");
        return true;
    }
}
