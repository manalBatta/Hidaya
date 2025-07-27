import { DefaultAuthProvider } from 'adminjs';
import componentLoader from './component-loader.js';
import { DEFAULT_ADMIN } from './constants.js';
<<<<<<< HEAD
/**
 * Make sure to modify "authenticate" to be a proper authentication method
 */
=======
>>>>>>> e220066e3fe0067d22590e4e5fe2e047ebafcd11
const provider = new DefaultAuthProvider({
    componentLoader,
    authenticate: async ({ email, password }) => {
        if (email === DEFAULT_ADMIN.email) {
            return { email };
        }
        return null;
    },
});
export default provider;
<<<<<<< HEAD
//# sourceMappingURL=auth-provider.js.map
=======
>>>>>>> e220066e3fe0067d22590e4e5fe2e047ebafcd11
