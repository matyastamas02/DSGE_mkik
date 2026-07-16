% jv_app_export.m — SCRIPT (nem függvény!): a base workspace oo_/options_-át
% használja a `dynare jv_app_model` után. Az IRF-eket az APP_OUT útvonalra írja.
% Az app -batch stringje beállítja APP_OUT-ot, majd meghívja ezt.
irfnev = fieldnames(oo_.irfs);
Tapp = table((1:options_.irf)', 'VariableNames', {'h'});
for ii_ = 1:numel(irfnev)
    Tapp.(irfnev{ii_}) = oo_.irfs.(irfnev{ii_})';
end
writetable(Tapp, APP_OUT);
fprintf('APP_EXPORT_OK %s\n', APP_OUT);
