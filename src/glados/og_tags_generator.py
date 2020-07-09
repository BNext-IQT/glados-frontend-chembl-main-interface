from django.conf import settings

import requests

# This uses elasticsearch to generate og tags for the main entities in ChEMBL (Compounds, Targets, Assays, Documents,
# Cell Lines, Tissues) and other pages. These tags are used to generate a preview when you share the page in social
# media

# --------------------------------------------------------------------------------------------------------------------
# Helper Functions
# --------------------------------------------------------------------------------------------------------------------


def add_attribute_to_description(description_items, item, attr_name, text_attr_name):

    attr_vale = item[attr_name]
    if attr_vale is not None:
        description_items.append("{}: {}".format(text_attr_name, attr_vale))

# --------------------------------------------------------------------------------------------------------------------
# Tag generation functions
# --------------------------------------------------------------------------------------------------------------------


def get_og_tags_for_compound(chembl_id):

    compound_url = f'{settings.ES_PROXY_API_BASE_URL}/es_data/get_es_document/chembl_molecule/{chembl_id}'

    doc_request = requests.get(compound_url)
    status_code = doc_request.status_code

    response_json = doc_request.json()

    title = 'Compound: '+ chembl_id
    description = 'Compound not found'
    if status_code == 200:
        description = ''
        description_items = []
        item = response_json['_source']
        # add the items to the description if they are available
        pref_name = item['pref_name']
        if pref_name is not None:
            title = 'Compound: '+ pref_name

        add_attribute_to_description(description_items, item, 'molecule_type', 'Molecule Type')

        try:
            mol_formula = item['molecule_properties']['full_molformula']
            description_items.append("Molecular Formula: {}".format(mol_formula))
        except (AttributeError, TypeError):
            pass

        try:
            mol_formula = item['molecule_properties']['full_mwt']
            description_items.append("Molecular Weight: {}".format(mol_formula))
        except (AttributeError, TypeError):
            pass

        synonyms = set()
        tradenames = set()
        raw_synonyms = item['molecule_synonyms']
        if raw_synonyms is not None:
            for raw_syn in raw_synonyms:
                if raw_syn['syn_type'] != 'TRADE_NAME':
                    synonyms.add(raw_syn['molecule_synonym'])
                else:
                    tradenames.add(raw_syn['molecule_synonym'])

            if len(synonyms) > 0:
                description_items.append("Synonyms: {}".format(";".join(synonyms)))
            if len(tradenames) > 0:
                description_items.append("Trade Names: {}".format(";".join(tradenames)))
        description = ', '.join(description_items)

    og_tags = {
        'chembl_id': chembl_id,
        'title': title,
        'description': description
    }
    return og_tags

def get_og_tags_for_target(chembl_id):

    compound_url = f'{settings.ES_PROXY_API_BASE_URL}/es_data/get_es_document/chembl_target/{chembl_id}'

    doc_request = requests.get(compound_url)
    status_code = doc_request.status_code

    response_json = doc_request.json()

    title = 'Target: ' + chembl_id
    description = 'Target not found'
    if status_code == 200:
        description = ''
        description_items = []
        item = response_json['_source']
        # add the items to the description if they are available
        pref_name = item['pref_name']
        if pref_name is not None:
            title = 'Target: ' + pref_name

        add_attribute_to_description(description_items, item, 'target_type', 'Type')
        add_attribute_to_description(description_items, item, 'organism', 'Organism')

        description = ', '.join(description_items)

    og_tags = {
        'chembl_id': chembl_id,
        'title': title,
        'description': description
    }
    return og_tags


def get_og_tags_for_assay(chembl_id):

    compound_url = f'{settings.ES_PROXY_API_BASE_URL}/es_data/get_es_document/chembl_target/{chembl_id}'

    doc_request = requests.get(compound_url)
    status_code = doc_request.status_code

    response_json = doc_request.json()

    title = 'Assay: ' + chembl_id
    description = 'Assay not found'
    if status_code == 200:
        description = ''
        description_items = []
        item = response_json['_source']
        # add the items to the description if they are available

        add_attribute_to_description(description_items, item, 'assay_type_description', 'Type')
        add_attribute_to_description(description_items, item, 'assay_organism', 'Organism')
        add_attribute_to_description(description_items, item, 'description', 'Description')

        description = ', '.join(description_items)

    og_tags = {
        'chembl_id': chembl_id,
        'title': title,
        'description': description
    }

    return og_tags

def get_og_tags_for_cell_line(chembl_id):

    compound_url = f'{settings.ES_PROXY_API_BASE_URL}/es_data/get_es_document/chembl_cell_line/{chembl_id}'

    doc_request = requests.get(compound_url)
    status_code = doc_request.status_code

    response_json = doc_request.json()

    title = 'Cell Line: ' + chembl_id
    description = 'Cell Line not found'

    if status_code == 200:
        description = ''
        description_items = []
        item = response_json['_source']
        # add the items to the description if they are available
        cell_name = item['cell_name']
        if cell_name is not None:
            title = 'Cell Line: ' + cell_name

        add_attribute_to_description(description_items, item, 'cell_source_organism', 'Source Organism')
        add_attribute_to_description(description_items, item, 'cell_source_tissue', 'Source Tissue')
        add_attribute_to_description(description_items, item, 'cell_description', 'Description')
        description = ', '.join(description_items)

    og_tags = {
        'chembl_id': chembl_id,
        'title': title,
        'description': description
    }

    return og_tags


def get_og_tags_for_tissue(chembl_id):

    compound_url = f'{settings.ES_PROXY_API_BASE_URL}/es_data/get_es_document/chembl_tissue/{chembl_id}'

    doc_request = requests.get(compound_url)
    status_code = doc_request.status_code

    response_json = doc_request.json()

    title = 'Tissue: ' + chembl_id
    description = 'Tissue not found'
    if status_code == 200:
        description = ''
        description_items = []
        item = response_json['_source']
        # add the items to the description if they are available
        pref_name = item['pref_name']
        if pref_name is not None:
            title = 'Tissue: ' + pref_name


    og_tags = {
        'chembl_id': chembl_id,
        'title': title,
        'description': ''
    }

    return og_tags


def get_og_tags_for_document(chembl_id):

    compound_url = f'{settings.ES_PROXY_API_BASE_URL}/es_data/get_es_document/chembl_document/{chembl_id}'

    doc_request = requests.get(compound_url)
    status_code = doc_request.status_code

    response_json = doc_request.json()

    title = 'Document: ' + chembl_id
    description = 'Document not found'
    if status_code == 200:
        description = ''
        description_items = []
        item = response_json['_source']
        # add the items to the description if they are available
        doc_title = item['title']
        if doc_title is not None:
            title = 'Document: ' + doc_title

        add_attribute_to_description(description_items, item, 'doc_type', 'Type')
        add_attribute_to_description(description_items, item, 'abstract', 'Abstract')
        add_attribute_to_description(description_items, item, 'journal', 'Journal')
        add_attribute_to_description(description_items, item, 'authors', 'Authors')
        description = ', '.join(description_items)

    og_tags = {
        'chembl_id': chembl_id,
        'title': title,
        'description': description
    }
    return og_tags