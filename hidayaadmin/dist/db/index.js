import mongoose from 'mongoose';
import { Database, Resource } from '@adminjs/mongoose';
import AdminJS from 'adminjs';
AdminJS.registerAdapter({ Database, Resource });
const initialize = async () => {
    console.log('DATABASE_URL:', process.env.DATABASE_URL);
    if (!process.env.DATABASE_URL) {
        throw new Error('DATABASE_URL is not defined');
    }
    const db = await mongoose.connect(process.env.DATABASE_URL);
    console.log('Connected to MongoDB:', db.connection.name);
    return { db };
};
export default initialize;
<<<<<<< HEAD
//# sourceMappingURL=index.js.map
=======
>>>>>>> e220066e3fe0067d22590e4e5fe2e047ebafcd11
