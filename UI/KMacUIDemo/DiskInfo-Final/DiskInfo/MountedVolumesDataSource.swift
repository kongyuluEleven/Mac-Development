/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Cocoa

class Section {

  class Item {
    let volume: VolumeInfo
    init(item: VolumeInfo) {
      self.volume = item
    }
  }

  let name: String
  let items: [Item]

  init(name: String, volumes: [VolumeInfo]) {
    self.name = name
    items = volumes.map {
      Item(item: $0)
    }
  }
}

class MountedVolumesDataSource: NSObject {

  var sections = [Section]()
  fileprivate var outlineView: NSOutlineView

  init(outlineView: NSOutlineView) {
    self.outlineView = outlineView
    super.init()
    self.outlineView.dataSource = self
  }

  func reload() {
    let mountedVolumes = VolumeInfo.mountedVolumes()

    let internalVolumes = mountedVolumes.filter {
      !$0.removable
      }.sorted {
        $0.name < $1.name
    }

    let removableVolumes = mountedVolumes.filter {
      $0.removable
      }.sorted {
        $0.name < $1.name
    }

    sections = [Section(name: "Internal", volumes: internalVolumes),
                Section(name: "Removable", volumes: removableVolumes)]

    outlineView.reloadData()
  }
}

extension MountedVolumesDataSource: NSOutlineViewDataSource {

  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    if item == nil {
      return sections.count
    } else if let section = item as? Section {
      return section.items.count
    } else {
      return 0
    }
  }

  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    if let section = item as? Section {
      return section.items[index]
    } else {
      return sections[index]
    }
  }

  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    return item is Section
  }
}
