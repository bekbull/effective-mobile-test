import Foundation

protocol NetworkServiceProtocol {
    func fetchTodos() async throws -> [TodoResponse]
}

final class NetworkService: NetworkServiceProtocol {
    private let session = URLSession.shared
    
    func fetchTodos() async throws -> [TodoResponse] {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(TodosResponse.self, from: data)
        return response.todos
    }
}

// MARK: - Response Models
struct TodosResponse: Codable {
    let todos: [TodoResponse]
}

struct TodoResponse: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

// MARK: - Network Errors
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}
