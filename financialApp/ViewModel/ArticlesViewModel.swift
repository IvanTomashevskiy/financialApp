import SwiftUI

@MainActor
class ArticlesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    
    @Published var searchText: String = ""
    
    private let service: CategoriesServiceProtocol
    
    init(service: CategoriesServiceProtocol = MockCategoriesService()) {
        self.service = service
    }
    
    func loadAll() async {
        do {
            categories = try await service.fetchAll()
        } catch {
            print("Fail:", error)
        }
    }
    
    func fuzzyMatch(_ searchPattern: String, _ targetText: String, maxDistance: Int = 2) -> Bool {
        let patternLowercased = searchPattern.lowercased()
        let textLowercased    = targetText.lowercased()
        
        let patternLength = patternLowercased.count
        let textLength    = textLowercased.count
        
        guard patternLength > 0, textLength > 0 else {
            return false
        }
        
        let patternCharacters = Array(patternLowercased)
        let textCharacters    = Array(textLowercased)
        
        // Максимальная стартовая позиция, с которой окно длины patternLength укладывается в текст
        let maxStartIndex = max(textLength - patternLength, 0)
        for startIndex in 0...maxStartIndex {
            let windowEndIndex = min(startIndex + patternLength, textLength)
            let textWindow     = Array(textCharacters[startIndex..<windowEndIndex])
            
            let editDistance = levenshteinDistance(
                between: patternCharacters,
                and: textWindow
            )
            
            if editDistance <= maxDistance {
                return true
            }
        }
        
        return false
    }

    private func levenshteinDistance(
        between sourceCharacters: [Character],
        and   targetCharacters: [Character]
    ) -> Int {
        let sourceLength = sourceCharacters.count
        let targetLength = targetCharacters.count
        
        // Матрица расстояний: (sourceLength+1) x (targetLength+1)
        var distanceMatrix = Array(
            repeating: Array(repeating: 0, count: targetLength + 1),
            count: sourceLength + 1
        )
        
        // Инициализация краёв матрицы
        for sourceIndex in 0...sourceLength {
            distanceMatrix[sourceIndex][0] = sourceIndex
        }
        for targetIndex in 0...targetLength {
            distanceMatrix[0][targetIndex] = targetIndex
        }
        
        // Заполнение матрицы
        for sourceIndex in 1...sourceLength {
            for targetIndex in 1...targetLength {
                if sourceCharacters[sourceIndex - 1] == targetCharacters[targetIndex - 1] {
                    distanceMatrix[sourceIndex][targetIndex] = distanceMatrix[sourceIndex - 1][targetIndex - 1]
                } else {
                    let deletionDistance     = distanceMatrix[sourceIndex - 1][targetIndex]
                    let insertionDistance    = distanceMatrix[sourceIndex][targetIndex - 1]
                    let substitutionDistance = distanceMatrix[sourceIndex - 1][targetIndex - 1]
                    
                    distanceMatrix[sourceIndex][targetIndex] =
                        1 + min(deletionDistance, insertionDistance, substitutionDistance)
                }
            }
        }
        
        return distanceMatrix[sourceLength][targetLength]
    }
    
    var filteredCategories: [Category] {
        guard !searchText.isEmpty else {
            return categories
        }
        return categories.filter { category in
            fuzzyMatch(searchText, category.name)
        }
    }
    
}
