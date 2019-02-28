import Foundation

class Parser {
    func read(_ file: String) -> Input {
        let url = Bundle.main.url(forResource: file, withExtension: "txt")!
        let contents = try! String(contentsOf: url)

        return Input(contents)
    }
}

enum ImageType {
    case horizontal, vertical
}

struct Image {
    var type: ImageType
    var tags: Set<String>

    init(line: String) {
        let comps = line.components(separatedBy: " ")
        self.type = comps[0] == "H" ? .horizontal : .vertical
        tags = Set(comps[2..<comps.count])
    }
}

class Input {
    var images = [Image]()
    init(_ contents: String) {
        let lines = contents.components(separatedBy: "\n").dropFirst().dropLast()
        for line in lines {
            images.append(Image(line: line))
        }
    }
}

let input = Parser().read("b_lovely_landscapes")

print(input.images)
