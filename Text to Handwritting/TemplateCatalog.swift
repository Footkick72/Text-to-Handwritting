//
//  TemplateCatalog.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/3/21.
//

import Foundation
import SwiftUI

var Templates = TemplateCatalog()

struct TemplateCatalog {
    var primary_template: String
    var templates: Dictionary<String,Template>
    
    let savePath = Bundle.main.resourcePath! + "/Templates/"
    
    init() {
        self.primary_template = "lined"
        self.templates = ["lined": Template(name: "lined",
                                            bg: UIImage(imageLiteralResourceName: "linedpaper.png"),
                                            margins: [40,20,100,160],
                                            size: 28),
                          "blank": Template(name: "blank",
                                            bg: UIImage(imageLiteralResourceName: "blankpaper.png"),
                                            margins: [50,50,50,50],
                                            size: 28)]
        self.load_templates()
    }
    
    func get_template() -> Template{
        return templates[primary_template]!
    }
    
    mutating func create_template(name: String, image: UIImage, margins: Array<Int>, font_size: Int) {
        self.templates[name] = Template(name: name,
                                        bg: image,
                                        margins: margins,
                                        size: font_size)
        self.save_templates()
    }
    
    func save_templates() {
        let manager = FilesManager()
        do { try manager.save(fileNamed: "templates.txt", data: templates.values.map({$0.name}).joined(separator: " ").data(using: .utf8)!) } catch {
            print("failed to save templates.txt: ")
            print(error)
        }
        for k in self.templates.keys {
            let template = self.templates[k]
            do {
                try manager.save(fileNamed: template!.name + ".template", data: template!.get_json_data())
            } catch { print(template!.name + "failed to save, continuing..."); continue }
        }
    }
    
    mutating func load_templates() {
        let manager = FilesManager()
        do {
            for name in String(data: try manager.read(fileNamed: "templates.txt"), encoding: .utf8)!.split(separator: " ") {
                let data = try manager.read(fileNamed: name + ".template")
                let decoder = JSONDecoder()
                let template = try decoder.decode(Template.self, from: data)
                self.templates[template.name] = template
            }
        } catch {
            print("Error loading templates: ")
            print(error)
        }
    }
}
