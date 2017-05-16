                  SELECT  --g_conc_request_id,
                          --g_org_id,
                          200,
                          pv.vendor_id,
                          pv.vendor_name,
                          substr(NVL(pvs.vat_registration_num,pv.vat_registration_num),1,11),
                          NULL,    -- taxpayer_id not required for payables as there is no need of B2C transactions
                          pvs.country,
                          ai.invoice_id,
                          ai.invoice_num,
                          ai.invoice_date,
                          ai.gl_date,
                          ai.invoice_type_lookup_code trx_type,
                          --alc.displayed_field payment_method,
                          DECODE(NVL(posted_flag,'N'),'Y','ACCOUNTED','UNACCOUNTED'),
                          aid.invoice_distribution_id,
                          aid.distribution_line_number,
                          aid.line_type_lookup_code ,    -- for tax lines always this value will be 'TAX'
			  -- DECODE(aid.line_type_lookup_code,'TAX',0,DECODE(ai.invoice_currency_code,g_currency_code,aid.amount, aid.base_amount)) assessable_amt,
                          DECODE(aid.line_type_lookup_code,'TAX',Decode(aid.tax_calculated_flag,'N',Decode(aid.global_attribute_category,'JE.IT.APXINWKB.DISTRIBUTIONS',Nvl(aid.global_attribute1,0),0),0),
						              DECODE(ai.invoice_currency_code,'EUR',aid.amount, aid.base_amount)) assessable_amt,
                          DECODE(aid.line_type_lookup_code,'TAX',DECODE(ai.invoice_currency_code,'EUR',aid.amount, aid.base_amount),0) vat_amt,
                          -- De momento no utilizamos metodo de pago
                          --NVL(aid.global_attribute11,g_default_payment_mode) payment_mode,
                          NVL(aid.global_attribute9,'N')  below_threshold_flag,
                          NVL(aid.global_attribute10,'N')  report_exclusion_flag,
                          aid.global_attribute8 contract_ident,
                          NVL(aid.global_attribute6,'N') adj_inv_flag,
                          decode(ai.invoice_type_lookup_code,'CREDIT',aid.parent_invoice_id,
                                                             'DEBIT',aid.parent_invoice_id,aid.global_attribute7)ORIG_TRX_ID,
                          DECODE(pvs.country,'IT',null,DECODE(NVL(pv.global_attribute6,'N'),'Y','PERSON','ORGANIZATION')) party_type,
                          DECODE(pvs.country,'IT',null,DECODE(NVL(pv.global_attribute6,'N'),'Y',pv.vendor_name,null)) indv_last_name,
                          DECODE(pvs.country,'IT',null,DECODE(NVL(pv.global_attribute6,'N'),'Y',pv.global_attribute4,null)) indv_first_name,
                          DECODE(pvs.country,'IT',null,DECODE(NVL(pv.global_attribute6,'N'),'Y',to_date(pv.global_attribute2,'RRRR/MM/DD HH24:MI:SS'),null)) INDV_PARTY_DOB,
                          DECODE(pvs.country,'IT',null,DECODE(NVL(pv.global_attribute6,'N'),'Y',pv.global_attribute3,null)) INDV_PARTY_CITY,
                          DECODE(pvs.country,'IT',null,DECODE(NVL(pv.global_attribute6,'N'),'Y',pv.global_attribute5,null)) INDV_PARTY_PROVINCE,
                          DECODE(pvs.country,'IT',null,DECODE(NVL(pv.global_attribute6,'N'),'N',pvs.city,null)) company_city,
                          DECODE(pvs.country,'IT',null,DECODE(NVL(pv.global_attribute6,'N'),'N', substr(pvs.address_line1||pvs.address_line2||pvs.address_line3,1,40),null)) company_address
                          
                          -- V?nculo entre factura y factura rectificativa, analizar en 2nd round
                          --is_cm_dm_line_consistent(200,DECODE(ai.invoice_type_lookup_code,'CREDIT',aid.parent_invoice_id,
                          --                                                                'DEBIT',aid.parent_invoice_id,
                          --                                                                 aid.global_attribute7),
                          --                        aid.line_type_lookup_code,aid.global_attribute9, aid.global_attribute10,
                          --                        aid.global_attribute8,aid.global_attribute11) INCONST_CM_DM_APPL_FLAG
                    FROM  ap_invoices_all ai,
                          ap_invoice_distributions_all aid,
                          po_vendors pv,
                          po_vendor_sites_all pvs,
                          AP_TAX_CODES_ALL atc
                          --ap_lookup_codes alc,
                          --per_all_people_f papf
                          -- Tabla para seleccionar la secuencias de la ventana de par?metros para Italia
                          --je_it_setup_doc_seqs ds
                   WHERE  ai.invoice_id        =  aid.invoice_id
                     AND  ai.invoice_id        =  643289
                     AND  ai.vendor_id         =  pv.vendor_id
                     AND  pv.vendor_id         =  pvs.vendor_id
                     AND  ai.vendor_site_id    =  pvs.vendor_site_id
                     AND  aid.line_type_lookup_code <> 'AWT'
                     --AND  NOT EXISTS (SELECT 1
                     --                   FROM ap_invoice_distributions_all aid1
                     --                  WHERE aid1.invoice_id = ai.invoice_id
                     --                    AND NVL(aid1.match_status_flag,'N') <>'A')
                     AND  (pv.vat_registration_num IS NOT NULL OR pvs.vat_registration_num IS NOT NULL)  -- only B2B invoices for payables.
                     --AND  ai.payment_method_lookup_code = alc.lookup_code
                     --AND  alc.lookup_type      =  'PAYMENT METHOD'
		                 AND  (pvs.country ='ES'  OR pvs.country IN ( select territory_code from FND_Territories where alternate_territory_code IS NOT NULL))
                     AND  aid.org_id = 278
                     AND  aid.set_of_books_id = 5007
                     -- we need to pick only IT countries and EU countries transactions.
		                 --AND  NVL(pv.employee_id, -99)   =  papf.person_id (+)
                     
                     -- Ser? una extracci?n diaria de los datos
                     
                     --AND  (TRUNC(aid.accounting_date) BETWEEN g_start_date AND g_end_date
                     --       OR ((ai.invoice_type_lookup_code in ('CREDIT','DEBIT') OR NVL(aid.global_attribute6,'N')='Y')
			               --           AND TRUNC(aid.accounting_date) BETWEEN g_start_date AND g_end_date_for_cm_dm))
                     
                     AND  aid.tax_code_id IS NOT NULL
                     
                     
                     
                     
                     
                     

