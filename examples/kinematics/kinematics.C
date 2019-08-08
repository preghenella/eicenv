#ifdef __CLING__
R__LOAD_LIBRARY(libDelphes);
#include "classes/DelphesClasses.h"
#include "external/ExRootAnalysis/ExRootTreeReader.h"
#endif

void kinematics(const Char_t *finname = "delphes.root", const Char_t *foutname = "kinematics.root",
		Double_t electronP = -10., Double_t protonP = 100.)
{

  /** open file and connect to tree **/
  auto fin = TFile::Open(finname);
  auto tin = (TTree *)fin->Get("Delphes");
  auto nevents = tin->GetEntries();
  TClonesArray *events = new TClonesArray("HepMCEvent");
  tin->SetBranchAddress("Event", &events);
  TClonesArray *particles = new TClonesArray("GenParticle");
  tin->SetBranchAddress("Particle", &particles);

  /** output file **/
  auto fout = TFile::Open(foutname, "RECREATE");

  /** output tree **/
  Double_t Q2, x, y, W2, ni;
  auto tout = new TTree("kinematics", "kinematics");
  tout->Branch("Q2", &Q2, "Q2/D");
  tout->Branch("x", &x, "x/D");
  tout->Branch("y", &y, "y/D");
  
  /** histograms **/
  auto hQ2x = new TH2F("hQ2x", ";log_{10} x; log_{10} Q^{2} (GeV^{2});#sigma (pb)", 50, -5., 0., 50, -1., 4.);
  
  /** vectors for kinematics **/
  TLorentzVector k, p, ko, q;
  k.SetXYZM(0., 0., electronP, 0.00051099891);
  p.SetXYZM(0., 0., protonP, 0.938270);

  /** store s **/
  auto s = (p + k).Mag2();
  auto hS = new TH1F("hS", ";;s (GeV^{2})", 1, 0., 1.);
  hS->SetBinContent(1, s);

  /** loop over events **/
  for (Int_t iev = 0; iev < nevents; ++iev) {
    tin->GetEntry(iev);

    /** find the outgoing electron **/
    auto npart = particles->GetEntries();
    for (Int_t ipart = 0; ipart < npart; ++ipart) {
      auto particle = (GenParticle *)particles->At(ipart);
      if (!particle) continue;
      if (particle->PID != 11) continue;
      ko.SetXYZM(particle->Px, particle->Py, particle->Pz, particle->Mass);
      break;
    }

    /** kinematics **/
    q = k - ko;
    Q2 = -q.Mag2();
    x = Q2 / (2. * p * q);
    y  = (q * p) / (k * p);
    W2 = (p + q).Mag2();
    ni = (q * p) / p.Mag();

    /** fill histograms **/
    hQ2x->Fill(log10(x), log10(Q2));

    /** fill tree **/
    tout->Fill();
    
  } /** end of loop over events **/

  /** get latest cross-section **/
  auto event = (HepMCEvent *)events->At(0);
  auto crossSection = event->CrossSection; // [pb]
  auto crossSectionError = event->CrossSectionError; // [pb]
  auto hXsec = new TH1F("hXsec", ";;#sigma (pb)", 1, 0., 1.);
  hXsec->SetBinContent(1, crossSection);
  hXsec->SetBinError(1, crossSectionError);
  
  /** normalise **/
  hQ2x->Scale(crossSection / nevents);

  /** write output and close **/
  fout->cd();
  hQ2x->Write();
  tout->Write();
  hXsec->Write();
  hS->Write();
  fout->Close();
  fin->Close();
  
}
