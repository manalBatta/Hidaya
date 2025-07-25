import { AdminJSOptions } from 'adminjs';

import User from '../models/User.js';

import Answers from 'src/models/Answers.js';
import Questions from 'src/models/Questions.js';

import Flags from 'src/models/Flags.js';
import Stories from 'src/models/Stories.js';
import Votes from 'src/models/Votes.js';
import componentLoader from './component-loader.js';

const options: AdminJSOptions = {
  componentLoader,
  rootPath: '/admin',
  resources: [User, Answers, Questions, Flags, Stories, Votes],
  databases: [],
};

export default options;
