var expect = require('chai').expect,
    app = require('../index');

describe('EmberAppDeploy', function() {
  it('exposes EmberAppDeploy', function() {
    expect(app.EmberAppDeploy).to.be.a('object');
  });
});