const express = require('express');
const multer = require('multer');
const { VertexAI } = require('google-cloud/vertexai');
const bodyParser = require('body-parser');

const app = express();

const PROJECT_ID = process.env.VERTEX_AI_PROJECT_ID;
const LOCATION = process.env.SERVER_LOCATION;