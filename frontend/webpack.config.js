const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const webpack = require('webpack');

module.exports = {
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js',
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env', '@babel/preset-react'],
          },
        },
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      },
    ],
  },
  mode: 'production',
  plugins: [
    new HtmlWebpackPlugin({
      template: './public/index.html',  
      filename: 'index.html'            
    }),
    new webpack.DefinePlugin({
      'process.env': {
        REACT_APP_POD_NAME: JSON.stringify('POD_NAME_PLACEHOLDER'),
        REACT_APP_POD_IP: JSON.stringify('POD_IP_PLACEHOLDER'),
      },
    }),
  ]
};