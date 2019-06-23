const fsextra = require('fs-extra')

const TestServer = require('./utils/testServer')

describe('api metadata endpoints', () => {
  const server = TestServer()

  const requestApi = () => server.request().get(`${server.config.serverPath}/api`)
  const requestMetadata = () => server.request().get(`${server.config.serverPath}/api/metadata`)

  before(() => server.start())
  after(() => server.stop())

  describe('api version', () => {
    it('reponds with server version', () => {
      const expectedVersion = 'v' + require('../package.json').version
      return requestApi()
        .expect(200)
        .then(response => {
          const version = response.text
          version.should.includes(expectedVersion)
          return requestApi().expect(200, version)
        })
    })
  })

  describe('metadata', () => {
    it('responds with size of requests-log-file', () => {
      const fileData = 'request \n request \n request \n request'
      fsextra.writeFileSync(server.config.requestslog, fileData)
      return requestMetadata()
        .expect(200)
        .then(response => {
          const metadata = response.body
          metadata.requestLogSize.should.equal(fileData.length)
        })
    })

    it('responds with 0 lines when no requests-log-file', () => {
      fsextra.removeSync(server.config.requestslog)
      return requestMetadata()
        .expect(200)
        .then(response => {
          const metadata = response.body
          metadata.requestLogSize.should.equal(0)
        })
    })
  })
})
