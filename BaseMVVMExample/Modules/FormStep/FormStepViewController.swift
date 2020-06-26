//
//  FormStepViewController.swift
//  BaseMVVMExample
//
//  Created by Admin on 19/03/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import UIKit
import IVCollectionKit

///
class FormStepViewController: BaseViewController, CollectionKeyboardAdjustable {
    
    typealias KeyboardAdjustmentTarget = FormStepViewController
    lazy var keyboardHandler: KeyboardNotificationsHandler<FormStepViewController> = localKeyboardHandler(adjustableTarget: self)
    var editingCollectionViewCell: UICollectionViewCell? {
        return collectionView.visibleCells
            .compactMap { $0 as? FormInputViewProtocol }
            .filter { $0.isEditing }
            .first as? UICollectionViewCell
    }
    
    func localKeyboardHandler<T: CollectionKeyboardAdjustable>(adjustableTarget: T) ->
        KeyboardNotificationsHandler<T> where T.KeyboardAdjustmentTarget: FormStepViewController {
        return KeyboardNotificationsHandler(source: adjustableTarget)
    }
    
    var viewModel: FormStepViewModelProtocol!
    var defaultCollectionBottomContentInset: CGFloat {
        return 10
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = FormStepCollectionViewLayout(
            hasHeader: viewModel.heading != nil,
            itemsSeparationStrategy: CollectionItemsSeparationStrategy.delegated(delegate: self))
        return UICollectionView(frame: view.bounds, collectionViewLayout: layout)
    }()
    lazy var director = CollectionDirector(colletionView: collectionView)
    
    let headingSection = CollectionSection()
    var inputSections: [CollectionSection] = []
    
    override var hasNavigationBar: Bool { return false }
    
    // MARK: Life cycle
    
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        setupCollectionView()
        configureCollectionView()
        observeKeyboardAdjustments()
    }
    
    // MARK: Setup
    
    /**
     */
    func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset.bottom = defaultCollectionBottomContentInset
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        director.shouldUseAutomaticViewRegistration = true
    }
    
    // MARK: Configuration
    
    /**
     */
    func configureCollectionView() {
        performCollectionViewConfiguration()
        director.reload()
    }
    
    /**
     Configures sections and adds them to the director
     */
    func performCollectionViewConfiguration() {
        configureHeadingSection(with: viewModel.heading)
        director += headingSection
        
        configureInputSections(with: viewModel.inputs)
        director.append(sections: inputSections)
    }
    
    /**
     */
    func configureHeadingSection(with headingViewModel: FormStepHeadingViewModelProtocol?, shouldReload: Bool = false) {
        headingSection.clear()
        if let viewModel = headingViewModel {
            headingSection += CollectionItem<FormStepHeadingCollectionViewCell>(item: viewModel)
        }
        if shouldReload {
            director.performUpdates(updates: { headingSection.reload() })
        }
    }
    
    /**
     */
    func configureInputSections(with inputViewModels: [AbstractFormInputViewModelProtocol], shouldReload: Bool = false) {
        inputSections.removeAll()
        var targetSection = CollectionSection()
        for inputViewModel in inputViewModels {
            if let radioButtonSelector = inputViewModel as? FormInputRadiobuttonSelectorViewModelProtocol {
                if !targetSection.isEmpty {
                    inputSections.append(targetSection)
                    targetSection = CollectionSection()
                }
                inputSections.append(makeRadioButtonsSection(with: radioButtonSelector))
            }
            else if let item = makeItem(with: inputViewModel) {
                targetSection.append(item: item)
            }
        }
        if !targetSection.isEmpty {
            inputSections.append(targetSection)
        }
        if shouldReload {
            director.performUpdates(updates: { inputSections.forEach { $0.reload() } })
        }
    }
    
    /**
     */
    func makeItem(with inputViewModel: AbstractFormInputViewModelProtocol) -> AbstractCollectionItem? {
        if let dateInputViewModel = inputViewModel as? FormInputViewModel<DateWrapper> {
            return CollectionItem<FormInputCollectionViewCell<DateWrapper>>(item: dateInputViewModel)
        }
        else if let stringInputViewModel = inputViewModel as? FormInputViewModel<String> {
            return CollectionItem<FormInputCollectionViewCell<String>>(item: stringInputViewModel)
        }
        else if let policyKindInputViewModel = inputViewModel as? FormInputViewModel<PolicyType.Kind> {
            return CollectionItem<FormInputCollectionViewCell<PolicyType.Kind>>(item: policyKindInputViewModel)
        }
        else if let fullNameInputViewModel = inputViewModel as? FormInputViewModel<FullName> {
            return CollectionItem<FormInputCollectionViewCell<FullName>>(item: fullNameInputViewModel)
        }
        else if let vehicleIdTypeViewModel = inputViewModel as? FormInputViewModel<Vehicle.Id.IdType> {
            return CollectionItem<FormInputCollectionViewCell<Vehicle.Id.IdType>>(item: vehicleIdTypeViewModel)
        }
        else if let vehicleSteeringWheelPicker = inputViewModel as? FormInputViewModel<Vehicle.SteeringWheelPosition> {
            return CollectionItem<FormInputCollectionViewCell<Vehicle.SteeringWheelPosition>>(item: vehicleSteeringWheelPicker)
        }
        else if let customPickerViewModel = inputViewModel as? FormInputCustomPickerViewModelProtocol {
            return CollectionItem<FormInputCustomPickerCollectionViewCell>(item: customPickerViewModel)
        }
        else if let checkboxViewModel = inputViewModel as? FormInputCheckboxViewModel {
            return CollectionItem<FormInputCheckboxCollectionViewCell>(item: checkboxViewModel)
        }
        return nil
    }
    
    /**
     */
    private func makeRadioButtonsSection(with selectorViewModel: FormInputRadiobuttonSelectorViewModelProtocol) -> RadiobuttonsCollectionSection {
        let radiobuttonsSection = RadiobuttonsCollectionSection()
        radiobuttonsSection.append(items: selectorViewModel.options.map(makeRadioButtonItem))
        return radiobuttonsSection
    }
    
    /**
     */
    private func makeRadioButtonItem(with optionViewModel: FormInputRadiobuttonOptionViewModelProtocol) -> AbstractCollectionItem {
        return CollectionItem<FormInputRadiobuttonCollectionViewCell>(item: optionViewModel)
    }
    
    /**
     */
    private func convertToInputIndexPath(indexPath: IndexPath) -> IndexPath? {
        let newSectionIndex = indexPath.section - 1
        guard (0 ..< inputSections.count) ~= newSectionIndex else { return nil }
        return IndexPath(item: indexPath.item, section: newSectionIndex)
    }
}

///
extension FormStepViewController: SeparatedItemsCollectionViewLayoutDelegate {
    
    /**
     */
    func separatedItemsCollectionViewLayout(_ layout: SeparatedItemsCollectionViewLayout, shouldDecorateItemAt indexPath: IndexPath) -> Bool {
        guard
            let indexPath = convertToInputIndexPath(indexPath: indexPath),
            inputSections.count > indexPath.section, inputSections[indexPath.section] is RadiobuttonsCollectionSection else {
            return false
        }
        return true
    }
    
    /**
     */
    func separatedItemsCollectionViewLayout(_ layout: SeparatedItemsCollectionViewLayout,
                                            splitterFrameForItemAt indexPath: IndexPath,
                                            ownedBy correspondingItemFrame: CGRect) -> CGRect {
        let defaultFrame = CGRect(x: 0,
                                  y: correspondingItemFrame.maxY-1,
                                  width: correspondingItemFrame.width,
                                  height: 1)
        guard
            let indexPath = convertToInputIndexPath(indexPath: indexPath),
            inputSections.count > indexPath.section,
            let section = inputSections[indexPath.section] as? RadiobuttonsCollectionSection,
            indexPath.item < section.numberOfItems() - 1 else { return defaultFrame }
        let leftInset: CGFloat = FormInputRadiobuttonCollectionViewCell.UIConstants.titleLeftInset
        return CGRect(origin: CGPoint(x: leftInset, y: defaultFrame.minY), size: CGSize(width: defaultFrame.width - leftInset, height: defaultFrame.height))
    }
}

///
fileprivate struct UIConstants {
    static let extraBottomInset: CGFloat = 10
}

///
fileprivate class RadiobuttonsCollectionSection: CollectionSection {}
