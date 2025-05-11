import XCTest

class BaseTest: XCTestCase {
    func dependencies() -> TestDependencySource? { return nil }
    func repositories() -> MockRepositoriesContainer? { return nil }
}

extension BaseTest {
    func makeDependencySource() -> TestDependencySource {
        guard var dSource = dependencies() else {
            fatalError("Override and configure your dependencies & repositories")
        }
        dSource._repositories = MockRepositories(container: repositories())
        if dSource._config == nil {
            dSource._config = MockEnvironmentConfiguration()
        }
        return dSource
    }
}
