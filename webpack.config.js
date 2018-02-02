var webpack = require("webpack");
var CopyWebpackPlugin = require('copy-webpack-plugin');
var ExtractTextPlugin = require("extract-text-webpack-plugin");
var path = require('path');


module.exports = {
  entry: './app/js/app.js',
  output: {
    path: path.resolve(__dirname, 'build'),
    filename: 'app.js'
  },
  module: {
    loaders: [
      { test: /\.(js|jsx|es6)$/, exclude: /node_modules/, loader: "babel-loader"},
      { test: /\.json$/i, loader: "json-loader"},
      { test: /\.sol/, loader: 'truffle-solidity-loader' }
    ]
  },
  plugins: [
    new CopyWebpackPlugin([
      { from: './app/index.html', to: "index.html" },
      { from: './app/images', to: "images" },
      { from: './app/fonts', to: "fonts" },
      { from: './app/css', to: "css" }
    ]),
  ],
  devServer: {
    stats: 'errors-only',
  }
};

