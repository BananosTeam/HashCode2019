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

class Image {
    var type: ImageType
    var tags: Set<NSString>

    init(line: String) {
        let comps = line.components(separatedBy: " ")
        self.type = comps[0] == "H" ? .horizontal : .vertical
        tags = Set(comps[2..<comps.count]) as Set<NSString>
    }

    func union(with other: Image) -> Set<NSString> {
//        var newSet = NSMutableSet()
//        for tag in tags {
//            newSet.add(tag)
//        }
//        for tag in other.tags {
//            newSet.add(tag)
//        }
//        return newSet
        return tags.union(other.tags)
    }
}

class Slide {
    var imagesID = [Int]()
    var tags: Set<NSString> = []
    var wasMatched = false

    init(imagesID: [Int], tags: Set<NSString>) {
        self.imagesID = imagesID
        self.tags = tags
    }

    func compare(_ other: Slide) -> Int {
//        var (union, first, second) = (0, 0, 0)
//        for tag in tags {
//            if other.tags.contains(tag) {
//                union += 1
//                continue
//            } else {
//                first += 1
//            }
//        }
//        for tag in other.tags {
//            if !tags.contains(tag) { second += 1}
//        }
//        return min(union, first, second)
        return min(tags.union(other.tags).count, tags.subtracting(other.tags).count, other.tags.subtracting(tags).count)
    }
}

class SlideWithInterest {
    let slide: Slide
    let interest: Int

    init(slide: Slide, interest: Int) {
        self.slide = slide
        self.interest = interest
    }
}

class Input {
    var images = [Image]()
    var horizontalImages = [Image]()
    var verticalImages = [Int: Image]()
    var slides = [Slide]()
    var finalSlides = [Slide]()
    init(_ contents: String) {
        let lines = contents.components(separatedBy: "\n").dropFirst().dropLast()
        let count = lines.count
        slides.reserveCapacity(count)
        images.reserveCapacity(count)
        horizontalImages.reserveCapacity(count)
        verticalImages.reserveCapacity(count)
        for (index, line) in lines.enumerated() {
            let image = Image(line: line)
            images.append(image)
            if image.type == .horizontal {
                horizontalImages.append(image)
                slides.append(Slide(imagesID: [index], tags: image.tags))
            } else {
                verticalImages[index] = image
            }
        }
    }

    func matchVerticalSlides() {
        var matchedIndices = Set<Int>()
        matchedIndices.reserveCapacity(verticalImages.count)
        if verticalImages.isEmpty { return }
        for (index1, image1) in verticalImages {
            if matchedIndices.contains(index1) { continue }
            var (max, maxIndex, maxSlide): (Int, Int, Slide?) = (0, 0, nil)
            for (index2, image2) in verticalImages {
                if matchedIndices.contains(index2) { continue }
                let newValue = image1.union(with: image2)
                if newValue.count > max {
                    max = newValue.count
                    maxIndex = index2
                    maxSlide = Slide(imagesID: [index1, index2], tags: newValue)
                }
//                let newSet = image1.union(with: image2)
//                if newSet.count > max {
//                    max = newSet.count
//                    maxIndex = index2
//                    maxSlide = Slide(imagesID: [index1, index2], tags: newSet)
//                }
            }
            matchedIndices.insert(index1)
            matchedIndices.insert(maxIndex)
            slides.append(maxSlide!)
//            slides.append(Slide(imagesID: [index1, maxIndex], tags: image1.tags.union(maxImage!.tags)))
        }
    }

    func sort() {
        slides.sort { $0.tags.count > $1.tags.count }
    }

    func matchSlides() {
        var matchedIndices = Set<Int>()
        let finalCount = slides.count
        matchedIndices.reserveCapacity(finalCount)
        finalSlides.reserveCapacity(finalCount)
        var matchedCount = 0
        var currentIndex = 0
        var slide = slides[currentIndex]
        finalSlides.append(slide)
        matchedIndices.insert(0)
        while matchedCount < finalCount - 1 {
            print(matchedCount)
            var (max, maxIndex): (Int, Int) = (0, 0)
            for (index, newSlide) in slides.enumerated() {
                if index == currentIndex || matchedIndices.contains(index) { continue }
                let newValue = slide.compare(newSlide)
                if newValue > max {
                    max = newValue
                    maxIndex = index
                }
            }
            matchedCount += 1
            slide = slides[maxIndex]
            finalSlides.append(slide)
            currentIndex = maxIndex
            matchedIndices.insert(maxIndex)
        }
    }

    var dictionary = NSMutableDictionary()
    func generateDictionary() {
        let count = slides.count
        dictionary = NSMutableDictionary(capacity: count)
        for i in 0..<count {
            dictionary[i] = NSMutableArray(capacity: count)
        }
        for (index1, slide1) in slides.enumerated() {
            print(index1)
            for (index2, slide2) in slides.suffix(from: index1).enumerated() {
                let interest = slide1.compare(slide2)
                if interest <= 0 { continue }
                (dictionary[index1] as! NSMutableArray).add(SlideWithInterest(slide: slide2, interest: interest))
                (dictionary[index2] as! NSMutableArray).add(SlideWithInterest(slide: slide1, interest: interest))
            }
        }
    }

    func outputResult() {
        var result = "\(finalSlides.count)"
        for slide in slides {
            result += "\n\(slide.imagesID.map { String(describing: $0) }.joined(separator: " "))"
        }
        print(result)
    }
}

let input = Parser().read("b_lovely_landscapes")
input.matchVerticalSlides()
input.sort()
input.generateDictionary()
//input.matchSlides()
//input.outputResult()
