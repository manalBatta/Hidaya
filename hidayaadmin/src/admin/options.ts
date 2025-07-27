import { AdminJSOptions } from 'adminjs';

import UserModel from '../../../backend/models/User.js';

import componentLoader from './component-loader.js';

const options: AdminJSOptions = {
  componentLoader,
  rootPath: '/admin',
  resources: [UserModel],
  databases: [],
};

export default options;
