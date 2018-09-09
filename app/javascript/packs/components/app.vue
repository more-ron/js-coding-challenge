<template lang="pug">
  #app
    .hero.is-primary
      .hero-body
        .container
          .title JS Coding Challenge: Amazon Product by ASIN
          .subtitle
            | Acceptance Criteria:
            ul
              li ✓ must be able to retrieve product information given ASIN (Amazon Standard Identification Number)
              li ✓ must be able to fetch product category
              li ✓ must be able to fetch product rank
              li ✓ must be able to fetch product dimensions
              li ✓ must be able to store data in some sort of database
              li ✓ must be able to display data on the frontend
    .section
      .container
        b-field(label="Amazon Standard Identification Number (ASIN):")
          b-input(v-model="asin" placeholder="ex: B002QYW8LW")

    .section
      .container
        .card(v-if="product")
          .card-content
            .media
              .media-left
                figure.image.is-128x128
                  img(:src="product.main_image")
              .media-content
                table.table.is-fullwidth
                  tbody
                    tr
                      th Product
                      td
                        a(:href="productUrl" target="_blank") {{ product.name }}
                    tr
                      th URL
                      td
                        a(:href="productUrl" target="_blank") {{ productUrl }}
                    tr
                      th ASIN
                      td
                        a(:href="productUrl" target="_blank") {{ product.asin }}
                    tr(v-if="product.main_category")
                      th Category
                      td {{ product.main_category }}
                    tr(v-if="product.rankings")
                      th Rankings
                      td
                        ul
                          li(v-for="ranking in product.rankings") Rank \#{{ ranking.rank }} in {{ ranking.category }}
                    tr(v-if="product.dimensions")
                      th Dimensions
                      td {{ product.dimensions }}
                    tr
                      th Last Updated
                      td {{ product.last_updated_at }}

          .card-footer
        b-message(v-if="error" title="Error!" type="is-danger") {{ error.message }}
    footer.footer
      .content
        p
          | Source:
          |
          a(href="https://github.com/more-ron/js-coding-challenge" target="_blank") more-ron/js-coding-challenge
</template>

<script>
import BField from "buefy/src/components/field/Field";

export default {
  components: { BField },
  data: function () {
    return {
      asin: null,
      product: null,
      error: null,
    }
  },
  computed: {
    productUrl() {
      return `https://www.amazon.com/dp/${this.asin}`;
    }
  },
  watch: {
    asin(_newValue, _oldValue) {
      let products = this.$resource('api/v1/products{/id}');
      if(this.asin.length >= 10) {
        const loadingComponent = this.$loading.open();

        products.get({id: this.asin})
          .then(response => {
            loadingComponent.close();
            this.error = null;
            this.product = response.body;
          }).catch(error => {
            loadingComponent.close();
            this.product = null;

            if(error.status === 404) {
              this.error = { message: `Product ${this.asin} not found!` }
            } else {
              this.error = { message: `Something went wrong. Please try again later.` }
              // TODO: report error here.
            }
        });
      }
    }
  },
}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
