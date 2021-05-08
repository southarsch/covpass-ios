//
//  VaccinationDetailViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import UIKit
import VaccinationCommon
import VaccinationUI

class VaccinationDetailViewModel {
    private let router: VaccinationDetailRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    private var certificates: [ExtendedCBORWebToken]
    public weak var delegate: ViewModelDelegate?

    // MARK: - Lifecyle

    init(
        router: VaccinationDetailRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        certificates: [ExtendedCBORWebToken]
    ) {
        self.router = router
        self.repository = repository
        self.certificates = certificates.sorted(by: { $0.vaccinationCertificate.hcert.dgc.v.first?.dn ?? 0 < $1.vaccinationCertificate.hcert.dgc.v.first?.dn ?? 0 })
    }

    // MARK: - Actions

    var fullImmunization: Bool {
        certificates.map { $0.vaccinationCertificate.hcert.dgc.fullImmunization }.first(where: { $0 }) ?? false
    }

    var isFavorite: Bool {
        do {
            let certList = try repository.getVaccinationCertificateList().wait()
            return certificates.contains(where: { $0.vaccinationCertificate.hcert.dgc.v.first?.ci == certList.favoriteCertificateId })
        } catch {
            return false
        }
    }

    var name: String {
        certificates.first?.vaccinationCertificate.hcert.dgc.nam.fullName ?? ""
    }

    var birthDate: String {
        guard let date = certificates.first?.vaccinationCertificate.hcert.dgc.dob else { return "" }
        return DateUtils.displayDateFormatter.string(from: date)
    }

    var immunizationIcon: UIImage? {
        UIImage(named: fullImmunization ? "status_full" : "status_partial", in: UIConstants.bundle, compatibleWith: nil)
    }

    var immunizationTitle: String {
        fullImmunization ? "vaccination_certificate_detail_view_complete_title".localized : String(format: "vaccination_certificate_detail_view_incomplete_title".localized, 1, 2)
    }

    var immunizationBody: String {
        fullImmunization ? "vaccination_certificate_detail_view_complete_message".localized : "vaccination_certificate_detail_view_incomplete_message".localized
    }

    var immunizationButton: String {
        fullImmunization ? "vaccination_certificate_detail_view_complete_action_button_title".localized : "vaccination_certificate_detail_view_incomplete_action_button_title".localized
    }

    var vaccinations: [VaccinationViewModel] {
        certificates.map { VaccinationViewModel(token: $0.vaccinationCertificate) }
    }

    func immunizationButtonTapped() {
        fullImmunization ?
            showCertificate() :
            scanNextCertificate()
    }

    func delete() {
        firstly {
            showDeleteDialog()
        }
        .then {
            self.repository.getVaccinationCertificateList()
        }
        .then { list -> Promise<VaccinationCertificateList> in
            var certList = list
            certList.certificates.removeAll(where: { certificate in
                for cert in self.certificates where cert == certificate {
                    return true
                }
                return false
            })
            return Promise.value(certList)
        }
        .then { list in
            self.repository.saveVaccinationCertificateList(list).asVoid()
        }
        .done {
            self.router.showCertificateOverview()
        }
        .catch { error in
            self.delegate?.viewModelUpdateDidFailWithError(error)
        }
    }

    func updateFavorite() -> Promise<Void> {
        firstly {
            repository.getVaccinationCertificateList()
        }
        .map { cert in
            var certList = cert
            guard let id = self.certificates.first?.vaccinationCertificate.hcert.dgc.v.first?.ci else {
                return certList
            }
            certList.favoriteCertificateId = certList.favoriteCertificateId == id ? nil : id
            return certList
        }
        .then { cert in
            self.repository.saveVaccinationCertificateList(cert).asVoid()
        }
    }

    func process(payload: String) -> Promise<Void> {
        firstly {
            repository.scanVaccinationCertificate(payload)
        }
        .then { cert in
            self.repository.getVaccinationCertificateList().then { list -> Promise<Void> in
                self.certificates = self.findCertificatePair(cert, list.certificates).sorted(by: { $0.vaccinationCertificate.hcert.dgc.v.first?.dn ?? 0 < $1.vaccinationCertificate.hcert.dgc.v.first?.dn ?? 0 })
                return Promise.value(())
            }
        }
    }

    func showErrorDialog() {
        router.showErrorDialog()
    }

    // MARK: - Private Helper

    private func findCertificatePair(_ certificate: ExtendedCBORWebToken, _ certificates: [ExtendedCBORWebToken]) -> [ExtendedCBORWebToken] {
        var list = [certificate]
        for cert in certificates where certificate.vaccinationCertificate.hcert.dgc == cert.vaccinationCertificate.hcert.dgc {
            if !list.contains(cert) {
                list.append(cert)
            }
        }
        return list
    }

    private func showDeleteDialog() -> Promise<Void> {
        .init { seal in
            let delete = DialogAction(title: "dialog_delete_certificate_button_delete".localized, style: .destructive) { _ in
                seal.fulfill_()
            }
            let cancel = DialogAction(title: "dialog_delete_certificate_button_cancel".localized, style: .cancel) { _ in
                seal.cancel()
            }
            let title = String(format: "dialog_delete_certificate_title".localized, self.name)
            self.router.showDialog(
                title: title,
                message: "dialog_delete_certificate_message".localized,
                actions: [delete, cancel],
                style: .alert
            )
        }
    }

    private func scanNextCertificate() {
        firstly {
            router.showScanner()
        }
        .then { result -> Promise<Void> in
            switch result {
            case let .success(qrCode):
                return self.process(payload: qrCode)
            case let .failure(error):
                throw error
            }
        }
        .done { [weak self] in
            self?.delegate?.viewModelDidUpdate()
        }
        .catch { [weak self] error in
            self?.delegate?.viewModelUpdateDidFailWithError(error)
        }
    }

    private func showCertificate() {
        router.showCertificateOverview()
    }
}
