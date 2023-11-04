program TConsulta_Lazarus_v1_0_0_3;

{$MODE Delphi}

uses
  {Vcl.Forms,}
  forms, Interfaces,
  uconsulta_lazarus in 'UConsulta_Lazarus.pas' {FConsulta};

{$R *.res}

begin
  Application.Initialize;
  //Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFConsulta, FConsulta);
  Application.Run;
end.
