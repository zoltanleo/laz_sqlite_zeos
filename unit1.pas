unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, memds, DateUtils, Forms, Controls, Graphics, Dialogs,
  DBGrids, ZDataset, ZConnection, ZAbstractRODataset;

type

  { TForm1 }

  TForm1 = class(TForm)
    ds: TDataSource;
    grTemp: TDBGrid;
    mds: TMemDataset;
    tmpConn: TZConnection;
    tmpQry: TZQuery;
    tmpTrans: TZTransaction;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

const
  SQLText =
    'SELECT ' +
        'P.ID' +
        ',P.LASTNAME' +
        ', P.FIRSTNAME' +
        ', P.THIRDNAME' +
        ', P.DATEBORN' +
        ', iif(P.SEX = 1,''male'',''female'') AS SEX ' +
    'FROM PERSONALITY P';

    SQLText_cnt =
    'SELECT count(P.ID) AS CNT ' +
    'FROM PERSONALITY P';

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  with mds do
  begin
    FieldDefs.Add('ID', ftInteger);
    FieldDefs.Add('LASTNAME', ftString, 100);
    FieldDefs.Add('FIRSTNAME', ftString, 100);
    FieldDefs.Add('THIRDNAME', ftString, 100);
    FieldDefs.Add('DATEBORN', ftDateTime);
    FieldDefs.Add('SEX', ftString, 6);

    CreateTable;
    Filtered:= False;
    Active := True;
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
var
  tc, tc_cnt: QWord;
begin
  tmpConn.Connected:= True;
  try
    tc:= GetTickCount64;
    tmpQry.DisableControls;
    try
      tmpTrans.StartTransaction;

      tmpQry.Active:= False;
      tmpQry.SQL.Text:= SQLText_cnt;
      tmpQry.Active:= True;
      tc_cnt:= GetTickCount64 - tc;
      tc:= GetTickCount64;

      tmpQry.Active:= False;
      tmpQry.SQL.Text:= SQLText;
      tmpQry.Active:= True;
      tmpQry.First;

      tmpTrans.Commit;
    except
      on E:EZDatabaseError do
      begin
        tmpTrans.Rollback;
        ShowMessage(E.Message);
      end;
    end;
  finally
    tmpQry.EnableControls;
    Self.Caption:= Format('Fetch time record count: %d ms/100К items %d ms', [tc_cnt, GetTickCount64 - tc]);
  end;
end;

end.

