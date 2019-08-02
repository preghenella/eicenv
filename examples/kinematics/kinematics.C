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

  /** histograms **/
  auto hQ2x = new TH2F("hQ2x", ";log_{10} x_{B}; log_{10} Q^{2} (GeV^{2});#sigma (pb)", 50, -5., 0., 50, -1., 4.);
  
  /** vectors for kinematics **/
  TLorentzVector k, p, ko, q;
  k.SetXYZM(0., 0., electronP, 0.00051099891);
  p.SetXYZM(0., 0., protonP, 0.938270);
  
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
    auto Q2 = -q.Mag2();
    auto xB = Q2 / (2. * p * q);
    auto y  = (q * p) / (k * p);
    auto W2 = (p + q).Mag2();
    auto ni = (q * p) / p.Mag();

    /** fill histograms **/
    hQ2x->Fill(log10(xB), log10(Q2));
    
  } /** end of loop over events **/

  /** get latest cross-section **/
  auto event = (HepMCEvent *)events->At(0);
  auto crossSection = event->CrossSection; // [pb]

  /** normalise **/
  hQ2x->Scale(crossSection / nevents);

  /** write output and close **/
  auto fout = TFile::Open(foutname, "RECREATE");
  hQ2x->Write();
  fout->Close();
  fin->Close();
  
}