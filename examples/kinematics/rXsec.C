/** DIS reduced cross-section **/

const Double_t hbarc2 = 0.389379; // [GeV2 mb]
const Double_t alpha = 1. / 137.036;
const Double_t alpha2 = alpha * alpha;

const Double_t ymin = 0.01;
const Double_t ymax = 0.95;

void
rXsec(const Char_t *finname = "kinematics.root",
      const Char_t *foutname = "rXsec.root",
      Double_t Q2min = 1., Double_t Q2max = -1.)
{

  /** open data **/
  auto fin = TFile::Open(finname);
  auto tin = (TTree *)fin->Get("kinematics");
  auto nevents = tin->GetEntries();
  Double_t Q2, x, y;
  tin->SetBranchAddress("Q2", &Q2);
  tin->SetBranchAddress("x", &x);
  tin->SetBranchAddress("y", &y);

  /** get s **/
  auto hS = (TH1F *)fin->Get("hS");
  auto s = hS->GetBinContent(1) / hS->GetEntries();

  /** get cross section **/
  auto hXsec = (TH1F *)fin->Get("hXsec");
  auto xsec_mb = hXsec->GetBinContent(1) / hXsec->GetEntries() * 1.e-9; // [mb]
  
  /** histograms **/
  auto hXsec_x = new TH1F("hXsec_x", Form("%.1f < Q^{2} < %.1f;log_{10} x; #sigma (mb)", Q2min, Q2max), 100, -5., 0.);
  auto hRedF_x = new TProfile("hRedF_x", Form("%.1f < Q^{2} < %.1f;log_{10} x; reduced factor", Q2min, Q2max), 100, -5., 0.);
  
  /** loop over events **/
  for (Int_t iev = 0; iev < nevents; ++iev) {
    tin->GetEntry(iev);
    if (Q2 < Q2min || Q2 > Q2max) continue;
    auto Q4 = Q2 * Q2;
    auto Yplus = 1. + (1. - y) * (1. - y);
    auto reduced = x * Q4 / (2. * M_PI * alpha2 * Yplus);
    hXsec_x->Fill(log10(x));
    hRedF_x->Fill(log10(x), reduced);
  }

  /** reset bins outside the y cuts **/
  auto xmin = Q2min / s / ymax;
  auto xmax = Q2max / s / ymin;
  for (Int_t ix = 0; ix < hXsec_x->GetNbinsX(); ++ix) {
    auto vale = hXsec_x->GetBinError(ix + 1);
    if (vale == 0.) continue;
    auto xlo = pow(10., hXsec_x->GetXaxis()->GetBinLowEdge(ix + 1));
    auto xhi = pow(10., hXsec_x->GetXaxis()->GetBinUpEdge(ix + 1));
    if (xlo > xmin && xhi < xmax) continue;
    hXsec_x->SetBinContent(ix + 1, 0.);
    hXsec_x->SetBinError(ix + 1, 0.);
  }
  
  /** cross sections **/
  auto deltaQ2 = Q2max - Q2min;
  for (Int_t ix = 0; ix < hXsec_x->GetNbinsX(); ++ix) {
    auto xlo = pow(10., hXsec_x->GetXaxis()->GetBinLowEdge(ix + 1));
    auto xhi = pow(10., hXsec_x->GetXaxis()->GetBinUpEdge(ix + 1));
    auto deltax = xhi - xlo;
    auto val  = hXsec_x->GetBinContent(ix + 1);
    auto vale = hXsec_x->GetBinError(ix + 1);
    if (vale == 0.) continue;

    /** normalise by bin aera **/
    val /= (deltax * deltaQ2);
    vale /= (deltax * deltaQ2);
    
    /** normalise by number of events **/
    val /= nevents;
    vale /= nevents;
    
    /** normalise by cross-section **/
    val *= xsec_mb;
    vale *= xsec_mb;
      
    /** set values **/
    hXsec_x->SetBinContent(ix + 1, val);
    hXsec_x->SetBinError(ix + 1, vale);
   
  }

  /** compute reduced cross-section **/
  auto hrXsec_x = (TH1 *)hXsec_x->Clone("hrXsec_x");
  hrXsec_x->SetTitle(Form("%.1f < Q^{2} < %.1f;log_{10} x; #sigma_{r}", Q2min, Q2max));
  hrXsec_x->Scale(1. / hbarc2);
  hrXsec_x->Multiply(hRedF_x);
  
  auto fout = TFile::Open(foutname, "RECREATE");
  hXsec_x->Write();
  hrXsec_x->Write();
  fout->Close();
  fin->Close();
  
}
