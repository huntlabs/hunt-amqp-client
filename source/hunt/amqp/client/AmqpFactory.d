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
import hunt.net.AsyncResult;

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
        assert(conn !is null);
        conn.close(null);
    }

    IPooledObject makeObject() {
        // dfmt off
        auto promise = new FuturePromise!AmqpConnection();

        AmqpConnectionImpl conn = new AmqpConnectionImpl(null, _options, _proton, 
            (ar) {
                if(ar.succeeded()) {
                    promise.succeeded(ar.result());
                } else {
                    Throwable th = ar.cause();
                    warning(th.msg);
                    version(HUNT_DEWBUG) warning(th);
                    promise.failed(new Exception("Unable to connect to the broker."));
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
        trace("running here");
        auto pooledObj = cast(PooledObject!(AmqpConnection))obj;
        AmqpConnection conn = pooledObj.getObject();
        assert(conn !is null);

        return !conn.isClosed();
    }
}
