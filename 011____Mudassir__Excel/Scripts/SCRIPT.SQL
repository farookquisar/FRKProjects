
DROP TABLE STNSMTH_SUPPLIER_EXCEL_TL;
DROP TABLE STNSMTH_SUPPLIERS_TL;


CREATE TABLE STNSMTH_SUPPLIERS_TL (
    SUPPLIERS_id   NUMBER GENERATED ALWAYS AS IDENTITY,
    supplier_name varchar2(255),
    supplier_code varchar2(255),
    created_by                VARCHAR2(100),
    created_date              DATE,
    last_updated_by           VARCHAR2(100),
    last_updated_date         DATE,
    CONSTRAINT STNSMTH_SUPPLIERS_TL_pk PRIMARY KEY ( SUPPLIERS_id ),
    CONSTRAINT STNSMTH_SUPPLIERS_TL_uk unique ( supplier_name )
);






create or replace TRIGGER STNSMTH_SUPPLIERS_TL_TRG
BEFORE
insert or update or delete on STNSMTH_SUPPLIERS_TL
for each row
begin

      ------------------------------------------------------------------------
      --inserting
      if inserting then
      :new.CREATED_DATE    := SYSDATE;
      :new.CREATED_BY := NVL(v('APP_USER'),USER);


      :new.supplier_name:=initcap(replace(:new.supplier_name,'  ',' '));

      if :new.supplier_code is null THEN
      :new.supplier_code:=upper(replace(:new.supplier_name,' ','-'));
      :new.supplier_code:=replace(:new.supplier_code,'--','-');
      end if;
      end if;

      ------------------------------------------------------------------------
      --inserting or updating
      if inserting or updating then
      :new.LAST_UPDATED_DATE    := SYSDATE;
      :new.last_updated_by := NVL(v('APP_USER'),USER);
      end if;

end;
/


insert into STNSMTH_SUPPLIERS_TL (supplier_name) values ('KIRAN ENTERPRISES');
insert into STNSMTH_SUPPLIERS_TL (supplier_name) values ('KIRAN GRANITES');

--==============================================================================================================================================================

CREATE TABLE  STNSMTH_SUPPLIER_EXCEL_TL
(
          STNSMTH_SUPPLIER_EXCEL_ID NUMBER GENERATED ALWAYS AS IDENTITY   NOT NULL ENABLE,
          SUPPLIERS_ID NUMBER ,
          BILL_NO VARCHAR2(100) COLLATE USING_NLS_COMP,
          BILL_DATE DATE ,
          PARTICULERS VARCHAR2(255) COLLATE USING_NLS_COMP,
          ITEM_SIZE VARCHAR2(100) COLLATE USING_NLS_COMP,
          QTY NUMBER,
          RATE NUMBER,
          AMOUNT NUMBER ,
          PAYMENT NUMBER,
          PAYMENT_REF VARCHAR2(1000) COLLATE USING_NLS_COMP,
          BALANCE NUMBER,
          NOTES1 VARCHAR2(1000) COLLATE USING_NLS_COMP,
          NOTES2 VARCHAR2(1000) COLLATE USING_NLS_COMP,
          NOTES3 VARCHAR2(1000) COLLATE USING_NLS_COMP,
          NOTES4 VARCHAR2(1000) COLLATE USING_NLS_COMP,
          NOTES5 VARCHAR2(1000) COLLATE USING_NLS_COMP,
          CREATED_BY VARCHAR2(100) COLLATE USING_NLS_COMP,
          CREATED_DATE DATE,
          LAST_UPDATED_BY VARCHAR2(100) COLLATE USING_NLS_COMP,
          LAST_UPDATED_DATE DATE,
          IS_PAYMENT VARCHAR2(20) COLLATE USING_NLS_COMP DEFAULT 'N',
          CONSTRAINT STNSMTH_SUPPLIER_EXCEL_PK PRIMARY KEY (STNSMTH_SUPPLIER_EXCEL_ID),
          CONSTRAINT SUPPLIERS_id_fk FOREIGN KEY ( SUPPLIERS_id ) REFERENCES STNSMTH_SUPPLIERS_TL ( SUPPLIERS_id )
) DEFAULT COLLATION USING_NLS_COMP;

CREATE  INDEX  STNSMTH_SUPPLIER_EXCEL_indx1 ON  STNSMTH_SUPPLIER_EXCEL_TL (SUPPLIERS_id);

create or replace TRIGGER  STNSMTH_SUPPLIER_EXCEL_TRG
BEFORE
insert or update or delete on stnsmth_SUPPLIER_EXCEL_TL
for each row
DECLARE
      both_not_Allowed EXCEPTION;
      either_is_mandatory EXCEPTION;
      PRAGMA exception_init(both_not_Allowed, -20111);
      PRAGMA exception_init(either_is_mandatory, -20112);
begin
------------------------------------------------------------------------
--inserting
if inserting then
        :new.CREATED_DATE    := SYSDATE;
        :new.CREATED_BY := NVL(v('APP_USER'),USER);
end if;
------------------------------------------------------------------------
--inserting or updating
if inserting or updating then
        :new.LAST_UPDATED_DATE    := SYSDATE;
        :new.last_updated_by := NVL(v('APP_USER'),USER);
        :new.BILL_NO :=trim(:new.BILL_NO);

        IF :new.SUPPLIERS_ID IS NULL THEN
        :new.SUPPLIERS_ID:=v('P4_SUPPLIERS');
        END IF;
        IF :new.BILL_DATE IS NULL THEN
        :new.BILL_DATE:=SYSDATE;
        END IF;
        if :new.AMOUNT is null THEN
        :new.AMOUNT:=0;
        end if;
        if :new.PAYMENT is null THEN
        :new.PAYMENT:=0;
        end if;
        IF :new.AMOUNT>0 AND :new.PAYMENT>0 THEN
        raise_application_error(-20111,'ഒന്നുകിൽ PAYMENT അല്ലെങ്കിൽ AMOUNT. രണ്ടും കൊടുക്കാൻ പാടില്ല.');
        END IF;
        IF :new.BILL_NO is null  THEN
        raise_application_error(-20111,'Bill Number കൊടുത്തിട്ടില്ല.');
        END IF;
        IF :new.AMOUNT=0 AND :new.PAYMENT=0 THEN
        raise_application_error(-20112,'ഒന്നുകിൽ PAYMENT അല്ലെങ്കിൽ AMOUNT കൊടുക്കുക');
        END IF;
        IF :new.PAYMENT>0 THEN
        :new.IS_PAYMENT:='Y';
        :new.BILL_NO:='PAYMENT';
        ELSE
        :new.IS_PAYMENT:='N';
        END IF;
        IF :new.AMOUNT=0 AND :new.PAYMENT=0  AND NVL(:new.RATE,0)>0 AND NVL(:new.QTY,0)>0 THEN
        :new.AMOUNT:=:new.RATE*:new.QTY;
        END IF;
end if;
end;
/


CREATE OR REPLACE FORCE VIEW STNSMTH_SUPPLIER_EXCEL_V  AS
  select
        STNSMTH_SUPPLIER_EXCEL_ID,SUPPLIERS_ID,BILL_NO,BILL_DATE,PARTICULERS,ITEM_SIZE,QTY,RATE,AMOUNT,PAYMENT,
        PAYMENT_REF,BALANCE,NOTES1,NOTES2,NOTES3,NOTES4,NOTES5,CREATED_BY,CREATED_DATE,LAST_UPDATED_BY,LAST_UPDATED_DATE,IS_PAYMENT,
        to_char(BILL_DATE,'MON') trx_mnth
  from
     STNSMTH_SUPPLIER_EXCEL_TL
     order by bill_no ,LAST_UPDATED_DATE desc;
/
