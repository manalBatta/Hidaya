import express from 'express';
import AdminJS from 'adminjs';
import { buildAuthenticatedRouter } from '@adminjs/express';
import mongoose from 'mongoose';
import * as AdminJSMongoose from '@adminjs/mongoose';
import provider from './admin/auth-provider.js';
import options from './admin/options.js';
import initializeDb from './db/index.js';
const port = process.env.PORT || 3000;
const start = async () => {
    const app = express();
    await initializeDb()
        .then(({ db }) => {
        console.log('Database initialized:', db.connection.name);
    })
        .catch((err) => {
        console.error('Database initialization failed:', err);
    });
    const admin = new AdminJS(options);
    if (process.env.NODE_ENV === 'production') {
        await admin.initialize();
    }
    else {
        admin.watch();
    }
    const router = buildAuthenticatedRouter(admin, {
        cookiePassword: process.env.COOKIE_SECRET,
        cookieName: 'adminjs',
        provider,
    }, null, {
        secret: process.env.COOKIE_SECRET,
        saveUninitialized: true,
        resave: true,
    });
    AdminJS.registerAdapter({
        Resource: AdminJSMongoose.Resource,
        Database: AdminJSMongoose.Database,
    });
<<<<<<< HEAD
    await mongoose.connect(process.env.MONGO_URI);
=======
    await mongoose.connect(process.env.DATABASE_URL);
>>>>>>> e220066e3fe0067d22590e4e5fe2e047ebafcd11
    app.use(admin.options.rootPath, router);
    app.listen(port, () => {
        console.log(`AdminJS available at http://localhost:${port}${admin.options.rootPath}`);
    });
};
start();
<<<<<<< HEAD
//# sourceMappingURL=app.js.map
=======
>>>>>>> e220066e3fe0067d22590e4e5fe2e047ebafcd11
