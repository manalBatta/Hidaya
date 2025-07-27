import UserModel from '../../../backend/models/User.js';
import componentLoader from './component-loader.js';
const options = {
    componentLoader,
    rootPath: '/admin',
    resources: [UserModel],
    databases: [],
};
export default options;
//# sourceMappingURL=options.js.map