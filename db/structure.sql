--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

--
-- Name: beta_round; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE beta_round AS ENUM (
    'pre_release_testing',
    'mvp1a'
);


--
-- Name: user_source; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE user_source AS ENUM (
    'admin_invitation',
    'requested_invitation',
    'recipient_referral'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gift_products; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE gift_products (
    id integer NOT NULL,
    gift_id integer,
    product_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gifts; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE gifts (
    id integer NOT NULL,
    title character varying,
    description text,
    selling_price numeric(10,2),
    cost numeric(10,2),
    wrapt_sku character varying,
    date_available date DEFAULT '1900-01-01'::date NOT NULL,
    date_discontinued date DEFAULT '2999-12-31'::date NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    calculate_cost_from_products boolean DEFAULT true NOT NULL,
    calculate_price_from_products boolean DEFAULT true NOT NULL,
    product_category_id integer,
    product_subcategory_id integer,
    source_product_id integer,
    featured boolean DEFAULT false NOT NULL
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE products (
    id integer NOT NULL,
    title character varying,
    description text,
    price numeric(10,2),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    wrapt_sku character varying,
    vendor_id integer,
    vendor_retail_price numeric(10,2),
    wrapt_cost numeric(10,2),
    units_available integer DEFAULT 0 NOT NULL,
    vendor_sku character varying,
    notes text,
    source_vendor_id integer,
    product_category_id integer,
    product_subcategory_id integer
);


--
-- Name: calculated_gift_fields; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW calculated_gift_fields AS
 SELECT g.id,
    g.id AS gift_id,
        CASE
            WHEN g.calculate_cost_from_products THEN ( SELECT sum(p.wrapt_cost) AS sum
               FROM (products p
                 JOIN gift_products gp ON (((gp.gift_id = g.id) AND (gp.product_id = p.id)))))
            ELSE g.cost
        END AS cost,
        CASE
            WHEN g.calculate_price_from_products THEN ( SELECT sum(p.price) AS sum
               FROM (products p
                 JOIN gift_products gp ON (((gp.gift_id = g.id) AND (gp.product_id = p.id)))))
            ELSE g.selling_price
        END AS price
   FROM gifts g;


--
-- Name: charges; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE charges (
    id integer NOT NULL,
    charge_id integer,
    state character varying,
    description text,
    amount_in_cents integer,
    payment_made_at timestamp without time zone,
    declined_at timestamp without time zone,
    idempotency_key character varying,
    idempotency_key_expires_at timestamp without time zone,
    error_message text,
    metadata jsonb,
    token character varying,
    error_code character varying,
    error_param character varying,
    decline_code character varying,
    error_type character varying,
    http_status character varying,
    amount_refunded_in_cents integer,
    authed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: charges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE charges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE charges_id_seq OWNED BY charges.id;


--
-- Name: conditional_question_options; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE conditional_question_options (
    id integer NOT NULL,
    survey_question_id integer,
    survey_question_option_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: conditional_question_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE conditional_question_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conditional_question_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE conditional_question_options_id_seq OWNED BY conditional_question_options.id;


--
-- Name: customer_purchases; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE customer_purchases (
    id integer NOT NULL,
    charge_id integer,
    order_id integer,
    shipment_id integer,
    shipping_label_id integer,
    user_id integer,
    profile_id integer
);


--
-- Name: customer_purchases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE customer_purchases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_purchases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE customer_purchases_id_seq OWNED BY customer_purchases.id;


--
-- Name: evaluation_recommendations; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE evaluation_recommendations (
    id integer NOT NULL,
    score double precision DEFAULT 0.0 NOT NULL,
    training_set_evaluation_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    profile_set_survey_response_id integer,
    gift_id integer NOT NULL,
    "position" integer DEFAULT 0
);


--
-- Name: evaluation_recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE evaluation_recommendations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: evaluation_recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE evaluation_recommendations_id_seq OWNED BY evaluation_recommendations.id;


--
-- Name: gift_dislikes; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE gift_dislikes (
    id integer NOT NULL,
    profile_id integer,
    gift_id integer,
    reason integer,
    created_at timestamp without time zone
);


--
-- Name: gift_dislikes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gift_dislikes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gift_dislikes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gift_dislikes_id_seq OWNED BY gift_dislikes.id;


--
-- Name: gift_images; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE gift_images (
    id integer NOT NULL,
    gift_id integer,
    image character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "primary" boolean DEFAULT false NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    image_processed boolean DEFAULT false NOT NULL,
    product_image_id integer,
    type character varying,
    width integer DEFAULT 0 NOT NULL,
    height integer DEFAULT 0 NOT NULL
);


--
-- Name: gift_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gift_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gift_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gift_images_id_seq OWNED BY gift_images.id;


--
-- Name: gift_likes; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE gift_likes (
    id integer NOT NULL,
    gift_id integer,
    profile_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    reason integer
);


--
-- Name: gift_likes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gift_likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gift_likes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gift_likes_id_seq OWNED BY gift_likes.id;


--
-- Name: gift_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gift_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gift_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gift_products_id_seq OWNED BY gift_products.id;


--
-- Name: gift_question_impacts; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE gift_question_impacts (
    id integer NOT NULL,
    training_set_id integer NOT NULL,
    survey_question_id integer NOT NULL,
    range_impact_direct_correlation boolean DEFAULT true,
    question_impact double precision DEFAULT 0.0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    gift_id integer NOT NULL
);


--
-- Name: gift_question_impacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gift_question_impacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gift_question_impacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gift_question_impacts_id_seq OWNED BY gift_question_impacts.id;


--
-- Name: gift_recommendations; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE gift_recommendations (
    id integer NOT NULL,
    gift_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    profile_id integer,
    score double precision DEFAULT 0.0 NOT NULL,
    "position" integer DEFAULT 0
);


--
-- Name: gift_recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gift_recommendations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gift_recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gift_recommendations_id_seq OWNED BY gift_recommendations.id;


--
-- Name: gift_selections; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE gift_selections (
    id integer NOT NULL,
    profile_id integer,
    gift_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gift_selections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gift_selections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gift_selections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gift_selections_id_seq OWNED BY gift_selections.id;


--
-- Name: gifts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gifts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gifts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gifts_id_seq OWNED BY gifts.id;


--
-- Name: internal_order_numbers; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE internal_order_numbers
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999000000000
    CACHE 1;


--
-- Name: invitation_requests; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE invitation_requests (
    id integer NOT NULL,
    email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    invited_user_id integer,
    invited_at timestamp without time zone,
    how_found character varying
);


--
-- Name: invitation_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE invitation_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invitation_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE invitation_requests_id_seq OWNED BY invitation_requests.id;


--
-- Name: line_items; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE line_items (
    id integer NOT NULL,
    gift_id integer,
    order_id integer,
    accounted_for_in_inventory boolean DEFAULT false NOT NULL,
    price_per_each_in_dollars numeric,
    quantity integer,
    total_price_in_dollars numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE line_items_id_seq OWNED BY line_items.id;


--
-- Name: mvp1b_user_surveys; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE mvp1b_user_surveys (
    id integer NOT NULL,
    user_id integer,
    age character varying,
    gender character varying,
    zip character varying,
    response_confidence character varying,
    recommendation_confidence character varying,
    recommendation_comment text,
    would_use_again character varying,
    would_tell_friend character varying,
    would_create_wish_list character varying,
    would_pay character varying,
    pay_comment text,
    other_services text,
    mailing_address text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mvp1b_user_surveys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mvp1b_user_surveys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mvp1b_user_surveys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mvp1b_user_surveys_id_seq OWNED BY mvp1b_user_surveys.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE orders (
    id integer NOT NULL,
    shipping_carrier_id integer,
    user_id integer,
    order_number character varying,
    status character varying,
    customer_email character varying,
    customer_name character varying,
    recipient_name character varying,
    ship_address_1 character varying,
    ship_address_2 character varying,
    ship_address_3 character varying,
    ship_city character varying,
    ship_region character varying,
    ship_postal_code character varying,
    ship_country character varying,
    notes text,
    customer_shipping_cost_in_dollars numeric,
    actual_shipping_cost_in_dollars numeric,
    total_price_in_dollars numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    created_on date
);


--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE orders_id_seq OWNED BY orders.id;


--
-- Name: parcels; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE parcels (
    id integer NOT NULL,
    description character varying NOT NULL,
    length_in_inches numeric NOT NULL,
    width_in_inches numeric NOT NULL,
    height_in_inches numeric NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: parcels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE parcels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parcels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE parcels_id_seq OWNED BY parcels.id;


--
-- Name: product_categories; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE product_categories (
    id integer NOT NULL,
    name character varying,
    lft integer NOT NULL,
    rgt integer NOT NULL,
    parent_id integer,
    depth integer DEFAULT 0 NOT NULL,
    children_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    wrapt_sku_code character varying
);


--
-- Name: product_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE product_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE product_categories_id_seq OWNED BY product_categories.id;


--
-- Name: product_images; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE product_images (
    id integer NOT NULL,
    product_id integer,
    image character varying,
    sort_order integer DEFAULT 0 NOT NULL,
    "primary" boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_processed boolean DEFAULT false NOT NULL,
    width integer DEFAULT 0 NOT NULL,
    height integer DEFAULT 0 NOT NULL
);


--
-- Name: product_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE product_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE product_images_id_seq OWNED BY product_images.id;


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE products_id_seq OWNED BY products.id;


--
-- Name: profile_set_survey_responses; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE profile_set_survey_responses (
    id integer NOT NULL,
    name character varying,
    profile_set_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: profile_set_survey_responses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profile_set_survey_responses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profile_set_survey_responses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profile_set_survey_responses_id_seq OWNED BY profile_set_survey_responses.id;


--
-- Name: profile_sets; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE profile_sets (
    id integer NOT NULL,
    name character varying,
    survey_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: profile_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profile_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profile_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profile_sets_id_seq OWNED BY profile_sets.id;


--
-- Name: profile_traits_facets; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE profile_traits_facets (
    id integer NOT NULL,
    topic_id integer,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: profile_traits_facets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profile_traits_facets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profile_traits_facets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profile_traits_facets_id_seq OWNED BY profile_traits_facets.id;


--
-- Name: profile_traits_tags; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE profile_traits_tags (
    id integer NOT NULL,
    facet_id integer,
    name character varying,
    "position" integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: profile_traits_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profile_traits_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profile_traits_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profile_traits_tags_id_seq OWNED BY profile_traits_tags.id;


--
-- Name: profile_traits_topics; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE profile_traits_topics (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: profile_traits_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profile_traits_topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profile_traits_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profile_traits_topics_id_seq OWNED BY profile_traits_topics.id;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE profiles (
    id integer NOT NULL,
    email character varying,
    name character varying,
    owner_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    relationship character varying,
    recommendations_in_progress boolean DEFAULT false NOT NULL,
    recommendations_generated_at timestamp without time zone,
    recipient_access_token character varying,
    recipient_reviewed boolean DEFAULT false NOT NULL,
    recipient_invited_at timestamp without time zone,
    recommendation_stats text
);


--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profiles_id_seq OWNED BY profiles.id;


--
-- Name: purchase_order_line_items; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE purchase_order_line_items (
    id integer NOT NULL,
    purchase_order_id integer,
    line_item_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: purchase_order_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE purchase_order_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: purchase_order_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE purchase_order_line_items_id_seq OWNED BY purchase_order_line_items.id;


--
-- Name: purchase_orders; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE purchase_orders (
    id integer NOT NULL,
    vendor_id integer,
    order_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: purchase_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE purchase_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: purchase_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE purchase_orders_id_seq OWNED BY purchase_orders.id;


--
-- Name: recipient_gift_dislikes; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE recipient_gift_dislikes (
    id integer NOT NULL,
    gift_id integer,
    profile_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    reason integer
);


--
-- Name: recipient_gift_dislikes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE recipient_gift_dislikes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recipient_gift_dislikes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE recipient_gift_dislikes_id_seq OWNED BY recipient_gift_dislikes.id;


--
-- Name: recipient_gift_likes; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE recipient_gift_likes (
    id integer NOT NULL,
    profile_id integer,
    gift_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    reason integer
);


--
-- Name: recipient_gift_likes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE recipient_gift_likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recipient_gift_likes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE recipient_gift_likes_id_seq OWNED BY recipient_gift_likes.id;


--
-- Name: recipient_gift_selections; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE recipient_gift_selections (
    id integer NOT NULL,
    profile_id integer,
    gift_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: recipient_gift_selections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE recipient_gift_selections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recipient_gift_selections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE recipient_gift_selections_id_seq OWNED BY recipient_gift_selections.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: shipments; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE shipments (
    id integer NOT NULL,
    order_id integer,
    address_from jsonb,
    address_to jsonb,
    parcel jsonb,
    api_response jsonb,
    success boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: shipments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE shipments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE shipments_id_seq OWNED BY shipments.id;


--
-- Name: shipping_carriers; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE shipping_carriers (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: shipping_carriers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE shipping_carriers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shipping_carriers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE shipping_carriers_id_seq OWNED BY shipping_carriers.id;


--
-- Name: shipping_labels; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE shipping_labels (
    id integer NOT NULL,
    shipment_id integer,
    purchase_order_id integer,
    tracking_number character varying,
    api_response jsonb,
    success boolean,
    url text,
    shippo_object_id character varying,
    error_messages text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: shipping_labels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE shipping_labels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shipping_labels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE shipping_labels_id_seq OWNED BY shipping_labels.id;


--
-- Name: survey_question_options; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE survey_question_options (
    id integer NOT NULL,
    survey_question_id integer NOT NULL,
    text text,
    image character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    type character varying,
    explanation text,
    configuration_string character varying
);


--
-- Name: survey_question_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE survey_question_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_question_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE survey_question_options_id_seq OWNED BY survey_question_options.id;


--
-- Name: survey_question_response_options; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE survey_question_response_options (
    id integer NOT NULL,
    survey_question_response_id integer NOT NULL,
    survey_question_option_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: survey_question_response_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE survey_question_response_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_question_response_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE survey_question_response_options_id_seq OWNED BY survey_question_response_options.id;


--
-- Name: survey_question_responses; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE survey_question_responses (
    id integer NOT NULL,
    survey_response_id integer NOT NULL,
    survey_question_id integer NOT NULL,
    text_response text,
    range_response double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying,
    other_option_text text,
    survey_response_type character varying NOT NULL,
    answered_at timestamp without time zone
);


--
-- Name: survey_question_responses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE survey_question_responses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_question_responses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE survey_question_responses_id_seq OWNED BY survey_question_responses.id;


--
-- Name: survey_questions; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE survey_questions (
    id integer NOT NULL,
    survey_id integer NOT NULL,
    prompt text,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    type character varying,
    min_label character varying,
    max_label character varying,
    mid_label character varying,
    sort_order integer DEFAULT 0 NOT NULL,
    multiple_option_responses boolean DEFAULT false NOT NULL,
    include_other_option boolean DEFAULT false NOT NULL,
    code character varying,
    use_response_as_name boolean DEFAULT false NOT NULL,
    conditional_question_id integer,
    survey_section_id integer,
    yes_no_display boolean DEFAULT false NOT NULL,
    placeholder_text text,
    use_response_as_relationship boolean DEFAULT false NOT NULL,
    price_filter boolean DEFAULT false,
    category_filter boolean DEFAULT false
);


--
-- Name: survey_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE survey_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE survey_questions_id_seq OWNED BY survey_questions.id;


--
-- Name: survey_response_trait_evaluations; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE survey_response_trait_evaluations (
    id integer NOT NULL,
    response_id integer,
    trait_training_set_id integer,
    matched_tag_id_counts hstore DEFAULT ''::hstore,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    matching_in_progress boolean DEFAULT false NOT NULL
);


--
-- Name: survey_response_trait_evaluations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE survey_response_trait_evaluations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_response_trait_evaluations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE survey_response_trait_evaluations_id_seq OWNED BY survey_response_trait_evaluations.id;


--
-- Name: survey_responses; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE survey_responses (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    profile_id integer,
    survey_id integer,
    completed_at timestamp without time zone
);


--
-- Name: survey_responses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE survey_responses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_responses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE survey_responses_id_seq OWNED BY survey_responses.id;


--
-- Name: survey_sections; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE survey_sections (
    id integer NOT NULL,
    survey_id integer,
    name character varying,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    introduction_heading text,
    introduction_text text
);


--
-- Name: survey_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE survey_sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE survey_sections_id_seq OWNED BY survey_sections.id;


--
-- Name: surveys; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE surveys (
    id integer NOT NULL,
    title character varying,
    copy_in_progress boolean DEFAULT false NOT NULL,
    active boolean,
    published boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    test_mode boolean DEFAULT false
);


--
-- Name: surveys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE surveys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: surveys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE surveys_id_seq OWNED BY surveys.id;


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE taggings (
    id integer NOT NULL,
    tag_id integer,
    taggable_type character varying,
    taggable_id integer,
    tagger_type character varying,
    tagger_id integer,
    context character varying(128),
    created_at timestamp without time zone
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taggings_id_seq OWNED BY taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying,
    taggings_count integer DEFAULT 0
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: training_set_evaluations; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE training_set_evaluations (
    id integer NOT NULL,
    training_set_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    recommendations_in_progress boolean DEFAULT false NOT NULL
);


--
-- Name: training_set_evaluations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE training_set_evaluations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: training_set_evaluations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE training_set_evaluations_id_seq OWNED BY training_set_evaluations.id;


--
-- Name: training_set_response_impacts; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE training_set_response_impacts (
    id integer NOT NULL,
    survey_question_option_id integer,
    impact double precision DEFAULT 0.0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    gift_question_impact_id integer NOT NULL
);


--
-- Name: training_set_response_impacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE training_set_response_impacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: training_set_response_impacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE training_set_response_impacts_id_seq OWNED BY training_set_response_impacts.id;


--
-- Name: training_sets; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE training_sets (
    id integer NOT NULL,
    name character varying,
    survey_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    published boolean
);


--
-- Name: training_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE training_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: training_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE training_sets_id_seq OWNED BY training_sets.id;


--
-- Name: trait_response_impacts; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE trait_response_impacts (
    id integer NOT NULL,
    trait_training_set_question_id integer,
    survey_question_option_id integer,
    range_position integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    profile_traits_tag_id integer
);


--
-- Name: trait_response_impacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trait_response_impacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trait_response_impacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trait_response_impacts_id_seq OWNED BY trait_response_impacts.id;


--
-- Name: trait_training_set_questions; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE trait_training_set_questions (
    id integer NOT NULL,
    trait_training_set_id integer,
    question_id integer,
    facet_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: trait_training_set_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trait_training_set_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trait_training_set_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trait_training_set_questions_id_seq OWNED BY trait_training_set_questions.id;


--
-- Name: trait_training_sets; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE trait_training_sets (
    id integer NOT NULL,
    name character varying,
    survey_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: trait_training_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trait_training_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trait_training_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trait_training_sets_id_seq OWNED BY trait_training_sets.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE users (
    id integer NOT NULL,
    first_name character varying,
    last_name character varying,
    email character varying NOT NULL,
    crypted_password character varying,
    salt character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    remember_me_token character varying,
    remember_me_token_expires_at timestamp without time zone,
    reset_password_token character varying,
    reset_password_token_expires_at timestamp without time zone,
    reset_password_email_sent_at timestamp without time zone,
    admin boolean DEFAULT false NOT NULL,
    activation_state character varying,
    activation_token character varying,
    activation_token_expires_at timestamp without time zone,
    last_viewed_profile_id integer,
    source character varying,
    beta_round character varying,
    recipient_referring_profile_id integer,
    unmoderated_testing_platform boolean DEFAULT false NOT NULL,
    activation_token_generated_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: vendors; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE vendors (
    id integer NOT NULL,
    name character varying,
    address text,
    contact_name character varying,
    email character varying,
    phone character varying,
    notes text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    wrapt_sku_code character varying
);


--
-- Name: vendors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vendors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vendors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vendors_id_seq OWNED BY vendors.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY charges ALTER COLUMN id SET DEFAULT nextval('charges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY conditional_question_options ALTER COLUMN id SET DEFAULT nextval('conditional_question_options_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY customer_purchases ALTER COLUMN id SET DEFAULT nextval('customer_purchases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY evaluation_recommendations ALTER COLUMN id SET DEFAULT nextval('evaluation_recommendations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_dislikes ALTER COLUMN id SET DEFAULT nextval('gift_dislikes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_images ALTER COLUMN id SET DEFAULT nextval('gift_images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_likes ALTER COLUMN id SET DEFAULT nextval('gift_likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_products ALTER COLUMN id SET DEFAULT nextval('gift_products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_question_impacts ALTER COLUMN id SET DEFAULT nextval('gift_question_impacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_recommendations ALTER COLUMN id SET DEFAULT nextval('gift_recommendations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_selections ALTER COLUMN id SET DEFAULT nextval('gift_selections_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY gifts ALTER COLUMN id SET DEFAULT nextval('gifts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY invitation_requests ALTER COLUMN id SET DEFAULT nextval('invitation_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY line_items ALTER COLUMN id SET DEFAULT nextval('line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mvp1b_user_surveys ALTER COLUMN id SET DEFAULT nextval('mvp1b_user_surveys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders ALTER COLUMN id SET DEFAULT nextval('orders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY parcels ALTER COLUMN id SET DEFAULT nextval('parcels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_categories ALTER COLUMN id SET DEFAULT nextval('product_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_images ALTER COLUMN id SET DEFAULT nextval('product_images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY products ALTER COLUMN id SET DEFAULT nextval('products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profile_set_survey_responses ALTER COLUMN id SET DEFAULT nextval('profile_set_survey_responses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profile_sets ALTER COLUMN id SET DEFAULT nextval('profile_sets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profile_traits_facets ALTER COLUMN id SET DEFAULT nextval('profile_traits_facets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profile_traits_tags ALTER COLUMN id SET DEFAULT nextval('profile_traits_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profile_traits_topics ALTER COLUMN id SET DEFAULT nextval('profile_traits_topics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles ALTER COLUMN id SET DEFAULT nextval('profiles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY purchase_order_line_items ALTER COLUMN id SET DEFAULT nextval('purchase_order_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY purchase_orders ALTER COLUMN id SET DEFAULT nextval('purchase_orders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY recipient_gift_dislikes ALTER COLUMN id SET DEFAULT nextval('recipient_gift_dislikes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY recipient_gift_likes ALTER COLUMN id SET DEFAULT nextval('recipient_gift_likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY recipient_gift_selections ALTER COLUMN id SET DEFAULT nextval('recipient_gift_selections_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY shipments ALTER COLUMN id SET DEFAULT nextval('shipments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY shipping_carriers ALTER COLUMN id SET DEFAULT nextval('shipping_carriers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY shipping_labels ALTER COLUMN id SET DEFAULT nextval('shipping_labels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY survey_question_options ALTER COLUMN id SET DEFAULT nextval('survey_question_options_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY survey_question_response_options ALTER COLUMN id SET DEFAULT nextval('survey_question_response_options_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY survey_question_responses ALTER COLUMN id SET DEFAULT nextval('survey_question_responses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY survey_questions ALTER COLUMN id SET DEFAULT nextval('survey_questions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY survey_response_trait_evaluations ALTER COLUMN id SET DEFAULT nextval('survey_response_trait_evaluations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY survey_responses ALTER COLUMN id SET DEFAULT nextval('survey_responses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY survey_sections ALTER COLUMN id SET DEFAULT nextval('survey_sections_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY surveys ALTER COLUMN id SET DEFAULT nextval('surveys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY training_set_evaluations ALTER COLUMN id SET DEFAULT nextval('training_set_evaluations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY training_set_response_impacts ALTER COLUMN id SET DEFAULT nextval('training_set_response_impacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY training_sets ALTER COLUMN id SET DEFAULT nextval('training_sets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trait_response_impacts ALTER COLUMN id SET DEFAULT nextval('trait_response_impacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trait_training_set_questions ALTER COLUMN id SET DEFAULT nextval('trait_training_set_questions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trait_training_sets ALTER COLUMN id SET DEFAULT nextval('trait_training_sets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vendors ALTER COLUMN id SET DEFAULT nextval('vendors_id_seq'::regclass);


--
-- Name: ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: charges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY charges
    ADD CONSTRAINT charges_pkey PRIMARY KEY (id);


--
-- Name: conditional_question_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY conditional_question_options
    ADD CONSTRAINT conditional_question_options_pkey PRIMARY KEY (id);


--
-- Name: customer_purchases_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY customer_purchases
    ADD CONSTRAINT customer_purchases_pkey PRIMARY KEY (id);


--
-- Name: evaluation_recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY evaluation_recommendations
    ADD CONSTRAINT evaluation_recommendations_pkey PRIMARY KEY (id);


--
-- Name: gift_dislikes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY gift_dislikes
    ADD CONSTRAINT gift_dislikes_pkey PRIMARY KEY (id);


--
-- Name: gift_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY gift_images
    ADD CONSTRAINT gift_images_pkey PRIMARY KEY (id);


--
-- Name: gift_likes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY gift_likes
    ADD CONSTRAINT gift_likes_pkey PRIMARY KEY (id);


--
-- Name: gift_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY gift_products
    ADD CONSTRAINT gift_products_pkey PRIMARY KEY (id);


--
-- Name: gift_question_impacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY gift_question_impacts
    ADD CONSTRAINT gift_question_impacts_pkey PRIMARY KEY (id);


--
-- Name: gift_recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY gift_recommendations
    ADD CONSTRAINT gift_recommendations_pkey PRIMARY KEY (id);


--
-- Name: gift_selections_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY gift_selections
    ADD CONSTRAINT gift_selections_pkey PRIMARY KEY (id);


--
-- Name: gifts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY gifts
    ADD CONSTRAINT gifts_pkey PRIMARY KEY (id);


--
-- Name: invitation_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY invitation_requests
    ADD CONSTRAINT invitation_requests_pkey PRIMARY KEY (id);


--
-- Name: line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY line_items
    ADD CONSTRAINT line_items_pkey PRIMARY KEY (id);


--
-- Name: mvp1b_user_surveys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY mvp1b_user_surveys
    ADD CONSTRAINT mvp1b_user_surveys_pkey PRIMARY KEY (id);


--
-- Name: orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: parcels_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY parcels
    ADD CONSTRAINT parcels_pkey PRIMARY KEY (id);


--
-- Name: product_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (id);


--
-- Name: product_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY product_images
    ADD CONSTRAINT product_images_pkey PRIMARY KEY (id);


--
-- Name: products_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: profile_set_survey_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY profile_set_survey_responses
    ADD CONSTRAINT profile_set_survey_responses_pkey PRIMARY KEY (id);


--
-- Name: profile_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY profile_sets
    ADD CONSTRAINT profile_sets_pkey PRIMARY KEY (id);


--
-- Name: profile_traits_facets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY profile_traits_facets
    ADD CONSTRAINT profile_traits_facets_pkey PRIMARY KEY (id);


--
-- Name: profile_traits_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY profile_traits_tags
    ADD CONSTRAINT profile_traits_tags_pkey PRIMARY KEY (id);


--
-- Name: profile_traits_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY profile_traits_topics
    ADD CONSTRAINT profile_traits_topics_pkey PRIMARY KEY (id);


--
-- Name: profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: purchase_order_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY purchase_order_line_items
    ADD CONSTRAINT purchase_order_line_items_pkey PRIMARY KEY (id);


--
-- Name: purchase_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY purchase_orders
    ADD CONSTRAINT purchase_orders_pkey PRIMARY KEY (id);


--
-- Name: recipient_gift_dislikes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY recipient_gift_dislikes
    ADD CONSTRAINT recipient_gift_dislikes_pkey PRIMARY KEY (id);


--
-- Name: recipient_gift_likes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY recipient_gift_likes
    ADD CONSTRAINT recipient_gift_likes_pkey PRIMARY KEY (id);


--
-- Name: recipient_gift_selections_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY recipient_gift_selections
    ADD CONSTRAINT recipient_gift_selections_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY shipments
    ADD CONSTRAINT shipments_pkey PRIMARY KEY (id);


--
-- Name: shipping_carriers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY shipping_carriers
    ADD CONSTRAINT shipping_carriers_pkey PRIMARY KEY (id);


--
-- Name: shipping_labels_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY shipping_labels
    ADD CONSTRAINT shipping_labels_pkey PRIMARY KEY (id);


--
-- Name: survey_question_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY survey_question_options
    ADD CONSTRAINT survey_question_options_pkey PRIMARY KEY (id);


--
-- Name: survey_question_response_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY survey_question_response_options
    ADD CONSTRAINT survey_question_response_options_pkey PRIMARY KEY (id);


--
-- Name: survey_question_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY survey_question_responses
    ADD CONSTRAINT survey_question_responses_pkey PRIMARY KEY (id);


--
-- Name: survey_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY survey_questions
    ADD CONSTRAINT survey_questions_pkey PRIMARY KEY (id);


--
-- Name: survey_response_trait_evaluations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY survey_response_trait_evaluations
    ADD CONSTRAINT survey_response_trait_evaluations_pkey PRIMARY KEY (id);


--
-- Name: survey_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY survey_responses
    ADD CONSTRAINT survey_responses_pkey PRIMARY KEY (id);


--
-- Name: survey_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY survey_sections
    ADD CONSTRAINT survey_sections_pkey PRIMARY KEY (id);


--
-- Name: surveys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY surveys
    ADD CONSTRAINT surveys_pkey PRIMARY KEY (id);


--
-- Name: taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: training_set_evaluations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY training_set_evaluations
    ADD CONSTRAINT training_set_evaluations_pkey PRIMARY KEY (id);


--
-- Name: training_set_response_impacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY training_set_response_impacts
    ADD CONSTRAINT training_set_response_impacts_pkey PRIMARY KEY (id);


--
-- Name: training_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY training_sets
    ADD CONSTRAINT training_sets_pkey PRIMARY KEY (id);


--
-- Name: trait_response_impacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY trait_response_impacts
    ADD CONSTRAINT trait_response_impacts_pkey PRIMARY KEY (id);


--
-- Name: trait_training_set_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY trait_training_set_questions
    ADD CONSTRAINT trait_training_set_questions_pkey PRIMARY KEY (id);


--
-- Name: trait_training_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY trait_training_sets
    ADD CONSTRAINT trait_training_sets_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vendors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY vendors
    ADD CONSTRAINT vendors_pkey PRIMARY KEY (id);


--
-- Name: eval_rec_survey_response; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX eval_rec_survey_response ON evaluation_recommendations USING btree (profile_set_survey_response_id);


--
-- Name: index_conditional_question_options_on_survey_question_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_conditional_question_options_on_survey_question_id ON conditional_question_options USING btree (survey_question_id);


--
-- Name: index_conditional_question_options_on_survey_question_option_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_conditional_question_options_on_survey_question_option_id ON conditional_question_options USING btree (survey_question_option_id);


--
-- Name: index_customer_purchases_on_charge_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_customer_purchases_on_charge_id ON customer_purchases USING btree (charge_id);


--
-- Name: index_customer_purchases_on_order_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_customer_purchases_on_order_id ON customer_purchases USING btree (order_id);


--
-- Name: index_customer_purchases_on_profile_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_customer_purchases_on_profile_id ON customer_purchases USING btree (profile_id);


--
-- Name: index_customer_purchases_on_shipment_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_customer_purchases_on_shipment_id ON customer_purchases USING btree (shipment_id);


--
-- Name: index_customer_purchases_on_shipping_label_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_customer_purchases_on_shipping_label_id ON customer_purchases USING btree (shipping_label_id);


--
-- Name: index_customer_purchases_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_customer_purchases_on_user_id ON customer_purchases USING btree (user_id);


--
-- Name: index_evaluation_recommendations_on_gift_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_evaluation_recommendations_on_gift_id ON evaluation_recommendations USING btree (gift_id);


--
-- Name: index_evaluation_recommendations_on_training_set_evaluation_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_evaluation_recommendations_on_training_set_evaluation_id ON evaluation_recommendations USING btree (training_set_evaluation_id);


--
-- Name: index_gift_dislikes_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_dislikes_on_created_at ON gift_dislikes USING btree (created_at);


--
-- Name: index_gift_dislikes_on_gift_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_dislikes_on_gift_id ON gift_dislikes USING btree (gift_id);


--
-- Name: index_gift_dislikes_on_profile_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_dislikes_on_profile_id ON gift_dislikes USING btree (profile_id);


--
-- Name: index_gift_images_on_gift_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_images_on_gift_id ON gift_images USING btree (gift_id);


--
-- Name: index_gift_images_on_primary; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_images_on_primary ON gift_images USING btree ("primary");


--
-- Name: index_gift_images_on_product_image_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_images_on_product_image_id ON gift_images USING btree (product_image_id);


--
-- Name: index_gift_likes_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_likes_on_created_at ON gift_likes USING btree (created_at);


--
-- Name: index_gift_likes_on_gift_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_likes_on_gift_id ON gift_likes USING btree (gift_id);


--
-- Name: index_gift_likes_on_profile_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_likes_on_profile_id ON gift_likes USING btree (profile_id);


--
-- Name: index_gift_products_on_gift_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_products_on_gift_id ON gift_products USING btree (gift_id);


--
-- Name: index_gift_products_on_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_products_on_product_id ON gift_products USING btree (product_id);


--
-- Name: index_gift_question_impacts_on_gift_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_question_impacts_on_gift_id ON gift_question_impacts USING btree (gift_id);


--
-- Name: index_gift_question_impacts_on_survey_question_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_question_impacts_on_survey_question_id ON gift_question_impacts USING btree (survey_question_id);


--
-- Name: index_gift_question_impacts_on_training_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_question_impacts_on_training_set_id ON gift_question_impacts USING btree (training_set_id);


--
-- Name: index_gift_recommendations_on_gift_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_recommendations_on_gift_id ON gift_recommendations USING btree (gift_id);


--
-- Name: index_gift_recommendations_on_profile_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_recommendations_on_profile_id ON gift_recommendations USING btree (profile_id);


--
-- Name: index_gift_selections_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_selections_on_created_at ON gift_selections USING btree (created_at);


--
-- Name: index_gift_selections_on_gift_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_selections_on_gift_id ON gift_selections USING btree (gift_id);


--
-- Name: index_gift_selections_on_profile_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gift_selections_on_profile_id ON gift_selections USING btree (profile_id);


--
-- Name: index_gifts_on_product_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gifts_on_product_category_id ON gifts USING btree (product_category_id);


--
-- Name: index_gifts_on_wrapt_sku; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_gifts_on_wrapt_sku ON gifts USING btree (wrapt_sku);


--
-- Name: index_invitation_requests_on_invited_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_invitation_requests_on_invited_user_id ON invitation_requests USING btree (invited_user_id);


--
-- Name: index_line_items_on_gift_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_line_items_on_gift_id ON line_items USING btree (gift_id);


--
-- Name: index_mvp1b_user_surveys_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_mvp1b_user_surveys_on_user_id ON mvp1b_user_surveys USING btree (user_id);


--
-- Name: index_orders_on_shipping_carrier_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_orders_on_shipping_carrier_id ON orders USING btree (shipping_carrier_id);


--
-- Name: index_orders_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_orders_on_user_id ON orders USING btree (user_id);


--
-- Name: index_product_categories_on_lft; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_product_categories_on_lft ON product_categories USING btree (lft);


--
-- Name: index_product_categories_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_product_categories_on_parent_id ON product_categories USING btree (parent_id);


--
-- Name: index_product_categories_on_rgt; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_product_categories_on_rgt ON product_categories USING btree (rgt);


--
-- Name: index_product_categories_on_wrapt_sku_code; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_product_categories_on_wrapt_sku_code ON product_categories USING btree (wrapt_sku_code);


--
-- Name: index_product_images_on_primary; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_product_images_on_primary ON product_images USING btree ("primary");


--
-- Name: index_product_images_on_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_product_images_on_product_id ON product_images USING btree (product_id);


--
-- Name: index_products_on_product_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_products_on_product_category_id ON products USING btree (product_category_id);


--
-- Name: index_products_on_vendor_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_products_on_vendor_id ON products USING btree (vendor_id);


--
-- Name: index_products_on_wrapt_sku; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_products_on_wrapt_sku ON products USING btree (wrapt_sku);


--
-- Name: index_profile_set_survey_responses_on_profile_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_profile_set_survey_responses_on_profile_set_id ON profile_set_survey_responses USING btree (profile_set_id);


--
-- Name: index_profile_sets_on_survey_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_profile_sets_on_survey_id ON profile_sets USING btree (survey_id);


--
-- Name: index_profile_traits_facets_on_topic_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_profile_traits_facets_on_topic_id ON profile_traits_facets USING btree (topic_id);


--
-- Name: index_profile_traits_tags_on_facet_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_profile_traits_tags_on_facet_id ON profile_traits_tags USING btree (facet_id);


--
-- Name: index_profiles_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_profiles_on_created_at ON profiles USING btree (created_at);


--
-- Name: index_profiles_on_recipient_invited_at; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_profiles_on_recipient_invited_at ON profiles USING btree (recipient_invited_at);


--
-- Name: index_purchase_order_line_items_on_line_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_purchase_order_line_items_on_line_item_id ON purchase_order_line_items USING btree (line_item_id);


--
-- Name: index_purchase_order_line_items_on_purchase_order_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_purchase_order_line_items_on_purchase_order_id ON purchase_order_line_items USING btree (purchase_order_id);


--
-- Name: index_purchase_orders_on_order_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_purchase_orders_on_order_id ON purchase_orders USING btree (order_id);


--
-- Name: index_purchase_orders_on_vendor_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_purchase_orders_on_vendor_id ON purchase_orders USING btree (vendor_id);


--
-- Name: index_question_response_on_survey_response_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_question_response_on_survey_response_id ON survey_question_responses USING btree (survey_response_id);


--
-- Name: index_recipient_gift_dislikes_on_gift_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_recipient_gift_dislikes_on_gift_id ON recipient_gift_dislikes USING btree (gift_id);


--
-- Name: index_recipient_gift_dislikes_on_profile_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_recipient_gift_dislikes_on_profile_id ON recipient_gift_dislikes USING btree (profile_id);


--
-- Name: index_recipient_gift_likes_on_gift_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_recipient_gift_likes_on_gift_id ON recipient_gift_likes USING btree (gift_id);


--
-- Name: index_recipient_gift_likes_on_profile_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_recipient_gift_likes_on_profile_id ON recipient_gift_likes USING btree (profile_id);


--
-- Name: index_recipient_gift_selections_on_gift_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_recipient_gift_selections_on_gift_id ON recipient_gift_selections USING btree (gift_id);


--
-- Name: index_recipient_gift_selections_on_profile_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_recipient_gift_selections_on_profile_id ON recipient_gift_selections USING btree (profile_id);


--
-- Name: index_response_impacts_option_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_response_impacts_option_id ON training_set_response_impacts USING btree (survey_question_option_id);


--
-- Name: index_response_trait_evals_on_trait_training_set; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_response_trait_evals_on_trait_training_set ON survey_response_trait_evaluations USING btree (trait_training_set_id);


--
-- Name: index_shipments_on_order_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_shipments_on_order_id ON shipments USING btree (order_id);


--
-- Name: index_shipping_labels_on_purchase_order_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_shipping_labels_on_purchase_order_id ON shipping_labels USING btree (purchase_order_id);


--
-- Name: index_shipping_labels_on_shipment_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_shipping_labels_on_shipment_id ON shipping_labels USING btree (shipment_id);


--
-- Name: index_survey_question_options_on_survey_question_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_survey_question_options_on_survey_question_id ON survey_question_options USING btree (survey_question_id);


--
-- Name: index_survey_question_responses_on_answered_at; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_survey_question_responses_on_answered_at ON survey_question_responses USING btree (answered_at);


--
-- Name: index_survey_question_responses_on_survey_question_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_survey_question_responses_on_survey_question_id ON survey_question_responses USING btree (survey_question_id);


--
-- Name: index_survey_questions_on_survey_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_survey_questions_on_survey_id ON survey_questions USING btree (survey_id);


--
-- Name: index_survey_questions_on_survey_section_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_survey_questions_on_survey_section_id ON survey_questions USING btree (survey_section_id);


--
-- Name: index_survey_response_trait_evaluations_on_response_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_survey_response_trait_evaluations_on_response_id ON survey_response_trait_evaluations USING btree (response_id);


--
-- Name: index_survey_responses_on_completed_at; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_survey_responses_on_completed_at ON survey_responses USING btree (completed_at);


--
-- Name: index_survey_responses_on_profile_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_survey_responses_on_profile_id ON survey_responses USING btree (profile_id);


--
-- Name: index_survey_responses_on_survey_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_survey_responses_on_survey_id ON survey_responses USING btree (survey_id);


--
-- Name: index_survey_sections_on_survey_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_survey_sections_on_survey_id ON survey_sections USING btree (survey_id);


--
-- Name: index_taggings_on_context; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_taggings_on_context ON taggings USING btree (context);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_taggings_on_tag_id ON taggings USING btree (tag_id);


--
-- Name: index_taggings_on_taggable_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_taggings_on_taggable_id ON taggings USING btree (taggable_id);


--
-- Name: index_taggings_on_taggable_id_and_taggable_type_and_context; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_taggings_on_taggable_id_and_taggable_type_and_context ON taggings USING btree (taggable_id, taggable_type, context);


--
-- Name: index_taggings_on_taggable_type; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_taggings_on_taggable_type ON taggings USING btree (taggable_type);


--
-- Name: index_taggings_on_tagger_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_taggings_on_tagger_id ON taggings USING btree (tagger_id);


--
-- Name: index_taggings_on_tagger_id_and_tagger_type; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_taggings_on_tagger_id_and_tagger_type ON taggings USING btree (tagger_id, tagger_type);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_training_set_evaluations_on_training_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_training_set_evaluations_on_training_set_id ON training_set_evaluations USING btree (training_set_id);


--
-- Name: index_training_set_response_impacts_on_gift_question_impact_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_training_set_response_impacts_on_gift_question_impact_id ON training_set_response_impacts USING btree (gift_question_impact_id);


--
-- Name: index_training_sets_on_survey_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_training_sets_on_survey_id ON training_sets USING btree (survey_id);


--
-- Name: index_trait_evaluations_on_matched_tag_id_counts; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_trait_evaluations_on_matched_tag_id_counts ON survey_response_trait_evaluations USING gin (matched_tag_id_counts);


--
-- Name: index_trait_response_impacts_on_profile_traits_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_trait_response_impacts_on_profile_traits_tag_id ON trait_response_impacts USING btree (profile_traits_tag_id);


--
-- Name: index_trait_response_impacts_on_survey_question_option_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_trait_response_impacts_on_survey_question_option_id ON trait_response_impacts USING btree (survey_question_option_id);


--
-- Name: index_trait_response_impacts_on_trait_training_set_question_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_trait_response_impacts_on_trait_training_set_question_id ON trait_response_impacts USING btree (trait_training_set_question_id);


--
-- Name: index_trait_training_set_questions_on_facet_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_trait_training_set_questions_on_facet_id ON trait_training_set_questions USING btree (facet_id);


--
-- Name: index_trait_training_set_questions_on_question_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_trait_training_set_questions_on_question_id ON trait_training_set_questions USING btree (question_id);


--
-- Name: index_trait_training_set_questions_on_trait_training_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_trait_training_set_questions_on_trait_training_set_id ON trait_training_set_questions USING btree (trait_training_set_id);


--
-- Name: index_trait_training_sets_on_survey_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_trait_training_sets_on_survey_id ON trait_training_sets USING btree (survey_id);


--
-- Name: index_users_on_activation_token; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_users_on_activation_token ON users USING btree (activation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_recipient_referring_profile_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_users_on_recipient_referring_profile_id ON users USING btree (recipient_referring_profile_id);


--
-- Name: index_users_on_remember_me_token; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_users_on_remember_me_token ON users USING btree (remember_me_token);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_vendors_on_wrapt_sku_code; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_vendors_on_wrapt_sku_code ON vendors USING btree (wrapt_sku_code);


--
-- Name: response_options_on_option_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX response_options_on_option_id ON survey_question_response_options USING btree (survey_question_option_id);


--
-- Name: response_options_on_response_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX response_options_on_response_id ON survey_question_response_options USING btree (survey_question_response_id);


--
-- Name: taggings_idx; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX taggings_idx ON taggings USING btree (tag_id, taggable_id, taggable_type, context, tagger_id, tagger_type);


--
-- Name: taggings_idy; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX taggings_idy ON taggings USING btree (taggable_id, taggable_type, tagger_id, context);


--
-- Name: attempt_calculated_gift_fields_del; Type: RULE; Schema: public; Owner: -
--

CREATE RULE attempt_calculated_gift_fields_del AS
    ON DELETE TO calculated_gift_fields DO INSTEAD NOTHING;


--
-- Name: attempt_calculated_gift_fields_up; Type: RULE; Schema: public; Owner: -
--

CREATE RULE attempt_calculated_gift_fields_up AS
    ON UPDATE TO calculated_gift_fields DO INSTEAD NOTHING;


--
-- Name: fk_rails_076023328d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY customer_purchases
    ADD CONSTRAINT fk_rails_076023328d FOREIGN KEY (shipment_id) REFERENCES shipments(id);


--
-- Name: fk_rails_0d540f40de; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY evaluation_recommendations
    ADD CONSTRAINT fk_rails_0d540f40de FOREIGN KEY (profile_set_survey_response_id) REFERENCES profile_set_survey_responses(id);


--
-- Name: fk_rails_16d6ff198a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_likes
    ADD CONSTRAINT fk_rails_16d6ff198a FOREIGN KEY (profile_id) REFERENCES profiles(id);


--
-- Name: fk_rails_1c991d3be6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_images
    ADD CONSTRAINT fk_rails_1c991d3be6 FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: fk_rails_233ae6f0fa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY evaluation_recommendations
    ADD CONSTRAINT fk_rails_233ae6f0fa FOREIGN KEY (gift_id) REFERENCES gifts(id);


--
-- Name: fk_rails_24f7836d52; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trait_training_set_questions
    ADD CONSTRAINT fk_rails_24f7836d52 FOREIGN KEY (question_id) REFERENCES survey_questions(id);


--
-- Name: fk_rails_2c01fd8bb6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY profile_set_survey_responses
    ADD CONSTRAINT fk_rails_2c01fd8bb6 FOREIGN KEY (profile_set_id) REFERENCES profile_sets(id);


--
-- Name: fk_rails_42747a8d20; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY survey_question_response_options
    ADD CONSTRAINT fk_rails_42747a8d20 FOREIGN KEY (survey_question_option_id) REFERENCES survey_question_options(id);


--
-- Name: fk_rails_4e95695f97; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY survey_question_responses
    ADD CONSTRAINT fk_rails_4e95695f97 FOREIGN KEY (survey_question_id) REFERENCES survey_questions(id);


--
-- Name: fk_rails_5007b05b14; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY customer_purchases
    ADD CONSTRAINT fk_rails_5007b05b14 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_52615103db; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY products
    ADD CONSTRAINT fk_rails_52615103db FOREIGN KEY (vendor_id) REFERENCES vendors(id);


--
-- Name: fk_rails_551435d92a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_selections
    ADD CONSTRAINT fk_rails_551435d92a FOREIGN KEY (profile_id) REFERENCES profiles(id);


--
-- Name: fk_rails_5c1abd7a16; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY purchase_orders
    ADD CONSTRAINT fk_rails_5c1abd7a16 FOREIGN KEY (vendor_id) REFERENCES vendors(id);


--
-- Name: fk_rails_5cd633a5f0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_question_impacts
    ADD CONSTRAINT fk_rails_5cd633a5f0 FOREIGN KEY (training_set_id) REFERENCES training_sets(id);


--
-- Name: fk_rails_609fa5239b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_recommendations
    ADD CONSTRAINT fk_rails_609fa5239b FOREIGN KEY (profile_id) REFERENCES profiles(id);


--
-- Name: fk_rails_62918e37d2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY customer_purchases
    ADD CONSTRAINT fk_rails_62918e37d2 FOREIGN KEY (shipping_label_id) REFERENCES shipping_labels(id);


--
-- Name: fk_rails_6739b67360; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shipping_labels
    ADD CONSTRAINT fk_rails_6739b67360 FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id);


--
-- Name: fk_rails_68a1b3d5ee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY purchase_order_line_items
    ADD CONSTRAINT fk_rails_68a1b3d5ee FOREIGN KEY (line_item_id) REFERENCES line_items(id);


--
-- Name: fk_rails_6a62b14582; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trait_response_impacts
    ADD CONSTRAINT fk_rails_6a62b14582 FOREIGN KEY (survey_question_option_id) REFERENCES survey_question_options(id);


--
-- Name: fk_rails_6ab48a186b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT fk_rails_6ab48a186b FOREIGN KEY (shipping_carrier_id) REFERENCES shipping_carriers(id);


--
-- Name: fk_rails_6ad12784ff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_question_impacts
    ADD CONSTRAINT fk_rails_6ad12784ff FOREIGN KEY (survey_question_id) REFERENCES survey_questions(id);


--
-- Name: fk_rails_6f302eea33; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_recommendations
    ADD CONSTRAINT fk_rails_6f302eea33 FOREIGN KEY (gift_id) REFERENCES gifts(id);


--
-- Name: fk_rails_75a344d89a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY profile_sets
    ADD CONSTRAINT fk_rails_75a344d89a FOREIGN KEY (survey_id) REFERENCES surveys(id);


--
-- Name: fk_rails_79f97e76bd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT fk_rails_79f97e76bd FOREIGN KEY (owner_id) REFERENCES users(id);


--
-- Name: fk_rails_7aca7ad7a9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trait_response_impacts
    ADD CONSTRAINT fk_rails_7aca7ad7a9 FOREIGN KEY (profile_traits_tag_id) REFERENCES profile_traits_tags(id);


--
-- Name: fk_rails_80eaabd48c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY survey_question_response_options
    ADD CONSTRAINT fk_rails_80eaabd48c FOREIGN KEY (survey_question_response_id) REFERENCES survey_question_responses(id);


--
-- Name: fk_rails_83ae7b10bb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shipping_labels
    ADD CONSTRAINT fk_rails_83ae7b10bb FOREIGN KEY (shipment_id) REFERENCES shipments(id);


--
-- Name: fk_rails_859af861a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY profile_traits_facets
    ADD CONSTRAINT fk_rails_859af861a3 FOREIGN KEY (topic_id) REFERENCES profile_traits_topics(id);


--
-- Name: fk_rails_85c91035a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY training_set_evaluations
    ADD CONSTRAINT fk_rails_85c91035a1 FOREIGN KEY (training_set_id) REFERENCES training_sets(id);


--
-- Name: fk_rails_8b24818c66; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_dislikes
    ADD CONSTRAINT fk_rails_8b24818c66 FOREIGN KEY (profile_id) REFERENCES profiles(id);


--
-- Name: fk_rails_9892d6a938; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY shipments
    ADD CONSTRAINT fk_rails_9892d6a938 FOREIGN KEY (order_id) REFERENCES orders(id);


--
-- Name: fk_rails_9b63456ac4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY survey_sections
    ADD CONSTRAINT fk_rails_9b63456ac4 FOREIGN KEY (survey_id) REFERENCES surveys(id);


--
-- Name: fk_rails_a05d8d21a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY profile_traits_tags
    ADD CONSTRAINT fk_rails_a05d8d21a6 FOREIGN KEY (facet_id) REFERENCES profile_traits_facets(id);


--
-- Name: fk_rails_a3d269d472; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_selections
    ADD CONSTRAINT fk_rails_a3d269d472 FOREIGN KEY (gift_id) REFERENCES gifts(id);


--
-- Name: fk_rails_a841c2fcee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY purchase_order_line_items
    ADD CONSTRAINT fk_rails_a841c2fcee FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id);


--
-- Name: fk_rails_ab268c7a4d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_likes
    ADD CONSTRAINT fk_rails_ab268c7a4d FOREIGN KEY (gift_id) REFERENCES gifts(id);


--
-- Name: fk_rails_abacffcac0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_products
    ADD CONSTRAINT fk_rails_abacffcac0 FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: fk_rails_b48a03c485; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY training_set_response_impacts
    ADD CONSTRAINT fk_rails_b48a03c485 FOREIGN KEY (gift_question_impact_id) REFERENCES gift_question_impacts(id);


--
-- Name: fk_rails_bc25ee4e95; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY conditional_question_options
    ADD CONSTRAINT fk_rails_bc25ee4e95 FOREIGN KEY (survey_question_option_id) REFERENCES survey_question_options(id);


--
-- Name: fk_rails_c5fca61a12; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_images
    ADD CONSTRAINT fk_rails_c5fca61a12 FOREIGN KEY (gift_id) REFERENCES gifts(id);


--
-- Name: fk_rails_ca4c0692c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_products
    ADD CONSTRAINT fk_rails_ca4c0692c0 FOREIGN KEY (gift_id) REFERENCES gifts(id);


--
-- Name: fk_rails_cb0b24fad0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trait_response_impacts
    ADD CONSTRAINT fk_rails_cb0b24fad0 FOREIGN KEY (trait_training_set_question_id) REFERENCES trait_training_set_questions(id);


--
-- Name: fk_rails_cb74764364; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trait_training_set_questions
    ADD CONSTRAINT fk_rails_cb74764364 FOREIGN KEY (trait_training_set_id) REFERENCES trait_training_sets(id);


--
-- Name: fk_rails_cf3fbfffed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_question_impacts
    ADD CONSTRAINT fk_rails_cf3fbfffed FOREIGN KEY (gift_id) REFERENCES gifts(id);


--
-- Name: fk_rails_d42aea1f2e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY customer_purchases
    ADD CONSTRAINT fk_rails_d42aea1f2e FOREIGN KEY (charge_id) REFERENCES charges(id);


--
-- Name: fk_rails_d66b19ca6c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY survey_responses
    ADD CONSTRAINT fk_rails_d66b19ca6c FOREIGN KEY (profile_id) REFERENCES profiles(id);


--
-- Name: fk_rails_daf14e8a00; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY customer_purchases
    ADD CONSTRAINT fk_rails_daf14e8a00 FOREIGN KEY (order_id) REFERENCES orders(id);


--
-- Name: fk_rails_dcc7f5b054; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_dislikes
    ADD CONSTRAINT fk_rails_dcc7f5b054 FOREIGN KEY (gift_id) REFERENCES gifts(id);


--
-- Name: fk_rails_e0b97cce56; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY purchase_orders
    ADD CONSTRAINT fk_rails_e0b97cce56 FOREIGN KEY (order_id) REFERENCES orders(id);


--
-- Name: fk_rails_ec71731d4b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY survey_responses
    ADD CONSTRAINT fk_rails_ec71731d4b FOREIGN KEY (survey_id) REFERENCES surveys(id);


--
-- Name: fk_rails_efe167855e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY products
    ADD CONSTRAINT fk_rails_efe167855e FOREIGN KEY (product_category_id) REFERENCES product_categories(id);


--
-- Name: fk_rails_f2f2f307d2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gifts
    ADD CONSTRAINT fk_rails_f2f2f307d2 FOREIGN KEY (product_category_id) REFERENCES product_categories(id);


--
-- Name: fk_rails_f2f9a0258f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY evaluation_recommendations
    ADD CONSTRAINT fk_rails_f2f9a0258f FOREIGN KEY (training_set_evaluation_id) REFERENCES training_set_evaluations(id);


--
-- Name: fk_rails_f39eaf89b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY line_items
    ADD CONSTRAINT fk_rails_f39eaf89b2 FOREIGN KEY (gift_id) REFERENCES gifts(id);


--
-- Name: fk_rails_f618a88677; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY customer_purchases
    ADD CONSTRAINT fk_rails_f618a88677 FOREIGN KEY (profile_id) REFERENCES profiles(id);


--
-- Name: fk_rails_f868b47f6a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT fk_rails_f868b47f6a FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_fced2efa88; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gift_images
    ADD CONSTRAINT fk_rails_fced2efa88 FOREIGN KEY (product_image_id) REFERENCES product_images(id);


--
-- Name: fk_rails_fd84648feb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trait_training_sets
    ADD CONSTRAINT fk_rails_fd84648feb FOREIGN KEY (survey_id) REFERENCES surveys(id);


--
-- Name: fk_rails_fe0c2ea380; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY conditional_question_options
    ADD CONSTRAINT fk_rails_fe0c2ea380 FOREIGN KEY (survey_question_id) REFERENCES survey_questions(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO "schema_migrations" (version) VALUES
('20160728174342'),
('20160728180413'),
('20160729152833'),
('20160729152944'),
('20160729165839'),
('20160801183308'),
('20160802132954'),
('20160802155523'),
('20160803170513'),
('20160803171141'),
('20160803171703'),
('20160810170208'),
('20160810172133'),
('20160811133418'),
('20160811182745'),
('20160812130104'),
('20160812144641'),
('20160812145332'),
('20160814194747'),
('20160814201543'),
('20160818133904'),
('20160818134423'),
('20160822125909'),
('20160822133153'),
('20160823135425'),
('20160824161236'),
('20160829140551'),
('20160829150430'),
('20160829154509'),
('20160913180316'),
('20160913180549'),
('20160914152150'),
('20160914172903'),
('20160914173215'),
('20160914174040'),
('20160914174432'),
('20160914175458'),
('20160915133014'),
('20160915184409'),
('20160916152207'),
('20160919141212'),
('20160919142057'),
('20160919142338'),
('20160919152725'),
('20160919173413'),
('20160919184737'),
('20160920180524'),
('20160920184518'),
('20160920185222'),
('20160921162011'),
('20160921162314'),
('20160922140221'),
('20160926182710'),
('20160928142732'),
('20160928181338'),
('20160928183050'),
('20160929180458'),
('20160929180824'),
('20160929181326'),
('20160929182522'),
('20160930180357'),
('20160930182523'),
('20161003175924'),
('20161003180153'),
('20161003180709'),
('20161004153234'),
('20161004153324'),
('20161004154929'),
('20161004181937'),
('20161005143748'),
('20161005145055'),
('20161006181023'),
('20161007174120'),
('20161011160009'),
('20161013140016'),
('20161013152515'),
('20161017140814'),
('20161024134919'),
('20161024144607'),
('20161024171011'),
('20161024181810'),
('20161026181950'),
('20161027144329'),
('20161028150104'),
('20161028171056'),
('20161102145233'),
('20161103164942'),
('20161104151357'),
('20161117154859'),
('20161117194621'),
('20161129161959'),
('20161129163512'),
('20161202153857'),
('20161202154954'),
('20161212180259'),
('20161216163331'),
('20161216191938'),
('20161216192233'),
('20161216192234'),
('20161216192235'),
('20161219211915'),
('20161220164347'),
('20161223172214'),
('20161223172334'),
('20170102195118'),
('20170102195658'),
('20170102205706'),
('20170102213626'),
('20170103153012'),
('20170103153044'),
('20170103153123'),
('20170103180426'),
('20170103180856'),
('20170104163227'),
('20170109153814'),
('20170109192732'),
('20170110074946'),
('20170111180116'),
('20170111181547'),
('20170113163420'),
('20170120150030'),
('20170120151453'),
('20170120164922'),
('20170120164952'),
('20170123153016'),
('20170124183417'),
('20170125181525'),
('20170125190531'),
('20170131171333'),
('20170202201459'),
('20170203184045'),
('20170203185334'),
('20170213192838'),
('20170215173329'),
('20170216182657'),
('20170216184242'),
('20170216212830'),
('20170217135548'),
('20170217145326'),
('20170217151144'),
('20170220190757'),
('20170220202141'),
('20170221192628'),
('20170221211612'),
('20170222153719'),
('20170222153845'),
('20170222183417'),
('20170302150531'),
('20170302154405'),
('20170309155537'),
('20170424145625'),
('20170426195607'),
('20170511145302'),
('20170512140119'),
('20170512140120'),
('20170512140121'),
('20170512140122'),
('20170512140123'),
('20170512140124'),
('20170518213211'),
('20170602141804'),
('20170609164649'),
('20170705192456'),
('20170829132311'),
('20170831164959');
