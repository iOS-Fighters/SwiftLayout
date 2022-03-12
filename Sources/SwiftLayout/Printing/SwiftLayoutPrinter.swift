//
//  SwiftLayoutPrinter.swift
//  
//
//  Created by oozoofrog on 2022/02/16.
//

import Foundation

public struct SwiftLayoutPrinter: CustomStringConvertible {
    public init(_ view: SLView, tags: [SLView: String] = [:]) {
        self.view = view
        self.tags = Dictionary(uniqueKeysWithValues: tags.map({ ($0.key.tagDescription, $0.value) }))
    }
    
    weak var view: SLView?
    let tags: [String: String]
    
    public var description: String {
        print()
    }
    
    /// print ``SwiftLayout`` syntax from view structures
    /// - Parameters:
    ///  - updater: ``IdentifierUpdater``
    ///  - systemConstraintsHidden: automatically assigned constraints from system hidden, default value is `true`
    ///  - printOnlyIdentifier: print view only having accessibility identifier
    /// - Returns: String of SwiftLayout syntax
    public func print(_ updater: IdentifierUpdater? = nil,
                      systemConstraintsHidden: Bool = true,
                      printOnlyIdentifier: Bool = false) -> String {
        guard let view = view else {
            return ""
        }
        
        if let updater = updater {
            updater.update(view, fixedTags: Set(tags.keys))
        }
        
        guard let viewToken = ViewToken.Parser.from(view, tags: tags, printOnlyIdentifier: printOnlyIdentifier) else { return "" }
        let constraints = ConstraintToken.Parser.from(view, tags: tags, systemConstraintsHidden: systemConstraintsHidden)
        return Describer(viewToken, constraints).description
    }
    
}

// MARK: - Describer
private struct Describer: CustomStringConvertible {
    
    init(_ token: ViewToken, _ constraints: [ConstraintToken]) {
        self.views = token.views
        self.constraints = constraints
        self.identifier = token.identifier
    }
    
    var description: String {
        if views.isEmpty {
            return fromConstraints(constraintsOfIdentifier, identifier: identifier).joined(separator: "\n")
        } else {
            return fromViews(constraintsOfIdentifier, views: views, identifier: identifier).joined(separator: "\n")
        }
    }
    
    private var constraintsOfIdentifier: [ConstraintToken]? {
        let constraints = constraints.filter({ $0.firstTag == identifier })
        if constraints.isEmpty { return nil }
        return constraints
    }
    
    private let views: [ViewToken]
    private let constraints: [ConstraintToken]
    private let identifier: String
    
    private func fromConstraints(_ constraints: [ConstraintToken]?, identifier: String) -> [String] {
        guard  let constraintTokens = constraints else { return [identifier] }
        var identifiers = [identifier + ".anchors {"]
        identifiers.append(ConstraintToken.Group(constraintTokens).description)
        identifiers.append("}")
        return identifiers
    }
    
    private func fromViews(_ constraints: [ConstraintToken]?, views: [ViewToken], identifier: String) -> [String] {
        var identifiers: [String] = []
        if constraints == nil {
            identifiers = [identifier + " {"]
        } else if let selfConstraints = constraints {
            identifiers = [identifier + ".anchors {"]
            identifiers.append(ConstraintToken.Group(selfConstraints).description)
            identifiers.append("}.sublayout {")
        } else {
            identifiers = [identifier + " {"]
        }
        identifiers.append(contentsOf: views.map({ view in
            let description = Describer(view, self.constraints).description
            return description.split(separator: "\n").map({ "\t" + $0 }).joined(separator: "\n")
        }))
        identifiers.append("}")
        return identifiers
    }
}

// MARK: - ViewToken
private struct ViewToken {
    private init(identifier: String, views: [ViewToken]) {
        self.identifier = identifier
        self.views = views
    }
    
    let identifier: String
    let views: [ViewToken]
    
    struct Parser {
        static func from(_ view: SLView, tags: [String: String], printOnlyIdentifier: Bool = false) -> ViewToken? {
            if let identifier = tags[view.tagDescription] {
                return ViewToken(identifier: identifier, views: view.subviews.compactMap({ from($0, tags: tags, printOnlyIdentifier: printOnlyIdentifier) }))
            } else {
                if printOnlyIdentifier {
                    if let identifier = view.slIdentifier, !identifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        return ViewToken(identifier: identifier, views: view.subviews.compactMap({ from($0, tags: tags, printOnlyIdentifier: printOnlyIdentifier) }))
                    } else {
                        return nil
                    }
                } else {
                    return ViewToken(identifier: view.tagDescription, views: view.subviews.compactMap({ from($0, tags: tags, printOnlyIdentifier: printOnlyIdentifier) }))
                }
            }
        }
    }
}

// MARK: - ConstraintToken
private struct ConstraintToken: CustomStringConvertible, Hashable {
    static func == (lhs: ConstraintToken, rhs: ConstraintToken) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    private init(constraint: SLLayoutConstraint, tags: [String: String]) {
        let tagger = Tagger(tags: tags)
        superTag = tagger.superTagFromItem(constraint.firstItem)
        firstTag = tagger.tagFromItem(constraint.firstItem)
        firstAttribute = constraint.firstAttribute.description
        firstAttributes = [firstAttribute]
        secondTag = tagger.tagFromItem(constraint.secondItem)
        secondAttribute = constraint.secondAttribute.description
        relation = constraint.relation.description
        constant = constraint.constant.description
        multiplier = constraint.multiplier.description
    }
    
    let superTag: String
    let firstTag: String
    let firstAttribute: String
    var firstAttributes: [String]
    let secondTag: String
    let secondAttribute: String
    let relation: String
    let constant: String
    let multiplier: String
    
    var description: String {
        var descriptions: [String] = ["Anchors(\(firstAttributes.map({ "." + $0 }).joined(separator: ", ")))"]
        var arguments: [String] = []
        if !secondTag.isEmpty && superTag != secondTag {
            arguments.append(secondTag)
        }
        if firstAttribute != secondAttribute && secondAttribute != SLLayoutConstraint.Attribute.notAnAttribute.description {
            arguments.append("attribute: .\(secondAttribute)")
        }
        if constant != "0.0" {
            arguments.append("constant: \(constant)")
        }
        if !arguments.isEmpty || relation != "equal" {
            descriptions.append("\(relation)To(\(arguments.joined(separator: ", ")))")
        }
        if multiplier != "1.0" {
            descriptions.append("setMultiplier(\(multiplier))")
        }
        return descriptions.joined(separator: ".")
    }
    
    func appendingFirstAttribute(_ firstAttribute: String) -> Self {
        var token = self
        token.firstAttributes.append(firstAttribute)
        return token
    }
    
    private func functionNameByRelation(_ relation: SLLayoutConstraint.Relation) -> String {
        relation.description
    }
    
    struct Parser {
        static func from(_ view: SLView, tags: [String: String], systemConstraintsHidden: Bool = true) -> [ConstraintToken] {
            let constraints = view.constraints
                .filter({ Validator.isUserCreation($0, systemConstraintsHidden: systemConstraintsHidden) })
            var tokens = constraints.map({ ConstraintToken(constraint: $0, tags: tags) })
            tokens.append(contentsOf: view.subviews.flatMap({ from($0, tags:tags, systemConstraintsHidden: systemConstraintsHidden) }))
            return tokens
        }
    }
    
    struct Validator {
        static func isUserCreation(_ constraint: SLLayoutConstraint, systemConstraintsHidden: Bool = true) -> Bool {
            let description = constraint.debugDescription
            if systemConstraintsHidden {
                guard description.contains("NSLayoutConstraint") else { return false }
                #if canImport(AppKit)
                guard let range = description.range(of: "'NSViewSafeAreaLayoutGuide-[:alpha:]*'", options: [.regularExpression], range: description.startIndex..<description.endIndex) else { return true }
                #else
                guard let range = description.range(of: "'UIViewSafeAreaLayoutGuide-[:alpha:]*'", options: [.regularExpression], range: description.startIndex..<description.endIndex) else { return true }
                #endif
                return range.isEmpty
            } else {
                return true
            }
        }
    }
    
    struct Tagger {
        let tags: [String: String]
        func tagFromItem(_ item: AnyObject?) -> String {
            if let view = item as? SLView {
                return tags[view.tagDescription] ?? view.tagDescription
            } else if let view = (item as? SLLayoutGuide)?.owningView {
                return tags[view.tagDescription].flatMap({ $0 + ".safeAreaLayoutGuide" }) ?? (view.tagDescription + ".safeAreaLayoutGuide")
            } else {
                return ""
            }
        }
        
        func superTagFromItem(_ item: AnyObject?) -> String {
            if let view = (item as? SLView)?.superview {
                return tagFromItem(view)
            } else if let view = (item as? SLLayoutGuide)?.owningView?.superview {
                return tagFromItem(view)
            } else {
                return tagFromItem(item)
            }
        }
        
    }
    
    struct Group: CustomStringConvertible {
        
        let tokens: [ConstraintToken]
        
        init(_ tokens: [ConstraintToken]) {
            self.tokens = tokens
        }
        
        var description: String {
            var mergedTokens: [ConstraintToken] = []
            for token in tokens {
                if mergedTokens.isEmpty {
                    mergedTokens.append(token)
                } else {
                    if let prevToken = mergedTokens.first(where: token.intersect) {
                        let newToken = prevToken.appendingFirstAttribute(token.firstAttribute)
                        guard let index = mergedTokens.firstIndex(of: prevToken) else { continue }
                        mergedTokens.remove(at: index)
                        mergedTokens.insert(contentsOf: [newToken], at: index)
                    } else {
                        mergedTokens.append(token)
                    }
                }
            }
            
            return mergedTokens.map({ "\t" + $0.description }).joined(separator: "\n")
        }
    }
    
    func intersect(_ token: ConstraintToken) -> Bool {
        return self.firstTag == token.firstTag
        && self.secondTag == token.secondTag
        && self.constant == token.constant
        && self.multiplier == token.multiplier
        && self.relation == token.relation
    }
}
