import UserModel from 'C:/Users/manal/Desktop/Hidaya/backend/models/User.js';
import componentLoader from './component-loader.js';
const options = {
    componentLoader,
    rootPath: '/admin',
    resources: [UserModel],
    databases: [],
};
export default options;
