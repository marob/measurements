STRIPE_ROWS <- 2
STRIPE_WIDTH <- 400
STRIPE_HEIGHT <- 250

plot_jdk_comparison <- function (data, name) {

    # Force factor order used by fixed scale.
    vm_values <- as.character (data %>% distinct(vm) %>% pull (vm) %>% str_sort(numeric = TRUE))
    data <- data %>% mutate (vm = factor (vm, levels = vm_values))

    nice <- ggplot (data, aes (x = vm, y = avg * 100, ymin = lo * 100, ymax = hi * 100, fill = vm)) +
        geom_col () +
        geom_errorbar (width = 0.5, color = '#555555') +
        facet_wrap (vars (benchmark), nrow = STRIPE_ROWS, scales = 'free_y', strip.position = 'bottom') +
        labs (x = NULL, y = sprintf('Performance compared to %s (reference) [%%]', vm_values %>% first()), fill = '') +
        theme (
            text = element_text (family = 'Serif', color = '#555555'),
            legend.position = 'bottom',
            axis.text.x = element_blank (),
            axis.ticks.x = element_blank (),
            axis.title.y = element_text (size = 14, margin = margin (r = 10)),
            strip.text.x = element_text (angle = 90, vjust = 0.5, hjust = 1, size = 14, color = '#555555'),
            strip.background = element_blank (),
            legend.text = element_text (size = 14),
            legend.title = element_text (size = 14),
            legend.background = element_rect (fill = 'transparent', color = NA),
            legend.box.background = element_rect (fill = 'transparent', color = NA),
            plot.background = element_rect (fill = 'transparent', color = NA)) +
        # The order of the scale must be the same as the order of the factor.
        scale_fill_manual (
            breaks = vm_values,
            values = c ('#ecd5a0', '#a73607', '#6e8ab1'))

    ggsave (name, nice, width = STRIPE_WIDTH, height = STRIPE_HEIGHT, unit = 'mm', bg = 'transparent')
}
