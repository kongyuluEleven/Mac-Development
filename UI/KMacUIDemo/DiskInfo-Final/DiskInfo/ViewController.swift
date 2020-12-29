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

class ViewController: NSViewController {

  fileprivate struct Constants {
    static let headerCellID = "HeaderCell"
    static let volumeCellID = "VolumeCell"
  }

  fileprivate var dataSource: MountedVolumesDataSource!
  fileprivate var delegate: MountedVolumesDelegate!
  fileprivate var bytesFormatter = ByteCountFormatter()

  @IBOutlet var outlineView: NSOutlineView!
  @IBOutlet var imageView: NSImageView!
  @IBOutlet var nameLabel: NSTextField!
  @IBOutlet var infoLabel: NSTextField!
  @IBOutlet weak var graphView: GraphView!

  override func viewDidLoad() {
    super.viewDidLoad()

    dataSource = MountedVolumesDataSource(outlineView: outlineView)
    delegate = MountedVolumesDelegate(outlineView: outlineView) { volume in
      self.showVolumeInfo(volume)
    }
  }

  override func viewWillAppear() {
    super.viewWillAppear()

    loadVolumes()
    selectFirstVolume()
  }

  func loadVolumes() {
    dataSource.reload()
    outlineView.expandItem(nil, expandChildren: true)
  }

  func selectFirstVolume() {
    guard let item = dataSource.sections.first?.items.first else {
      return
    }

    showVolumeInfo(item.volume)
    outlineView.selectRowIndexes(IndexSet(integer: outlineView.row(forItem: item)), byExtendingSelection: true)
  }

  func showVolumeInfo(_ volume: VolumeInfo) {
    imageView.image = volume.image
    nameLabel.stringValue = volume.name
    infoLabel.stringValue = "Capacity: \(bytesFormatter.string(fromByteCount: volume.capacity))." +
      "Available: \(bytesFormatter.string(fromByteCount: volume.available))"

    graphView.fileDistribution = volume.fileDistribution
  }
}
