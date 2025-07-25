import User from '../models/User.js';
import Answers from '../models/Answers.js';
import Questions from '../models/Questions.js';
import Flags from '../models/Flags.js';
import Stories from '../models/Stories.js';
import Votes from '../models/Votes.js';

import componentLoader from './component-loader.js';
const options = {
  componentLoader,
  rootPath: '/admin',
  resources: [User, Answers, Questions, Flags, Stories, Votes],
  databases: [],
};
export default options;
