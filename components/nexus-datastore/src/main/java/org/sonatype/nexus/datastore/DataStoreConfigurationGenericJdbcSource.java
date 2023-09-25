package org.sonatype.nexus.datastore;

import javax.annotation.Priority;
import javax.inject.Inject;
import javax.inject.Named;
import javax.inject.Singleton;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;
import org.sonatype.goodies.common.ComponentSupport;
import org.sonatype.nexus.datastore.api.DataStoreConfiguration;

import static com.google.common.base.Preconditions.checkArgument;
import static java.lang.Integer.MIN_VALUE;
import static org.sonatype.nexus.common.app.FeatureFlags.DATASTORE_GENERIC_JDBC_ENABLED_NAMED;
import static org.sonatype.nexus.datastore.api.DataStoreManager.DEFAULT_DATASTORE_NAME;


@Named(DataStoreConfigurationGenericJdbcSource.GENERIC_JDBC)
@Priority(MIN_VALUE + 10)
@Singleton
public class DataStoreConfigurationGenericJdbcSource
    extends ComponentSupport
    implements DataStoreConfigurationSource {

    static final String GENERIC_JDBC = "nexus";

    private static final String JDBC_TEMPLATE_URL = "${nexus.datastore.nexus.jdbcUrl}";

    private static final String JDBC = "jdbc";

    private static final String JDBC_URL = "jdbcUrl";

    private final boolean enabled;

    @Inject
    public DataStoreConfigurationGenericJdbcSource(@Named(DATASTORE_GENERIC_JDBC_ENABLED_NAMED) boolean enabled) {
        this.enabled = enabled || JDBC_TEMPLATE_URL.toLowerCase().contains("postgres");
    }

    @Override
    public String getName() {
        return GENERIC_JDBC;
    }

    @Override
    public boolean isModifiable() {
        return true;
    }

    @Override
    public Iterable<String> browseStoreNames() {
        return ImmutableSet.<String>builder().add(DEFAULT_DATASTORE_NAME).build();
    }

    @Override
    public boolean isEnabled() {
        return this.enabled;
    }

    @Override
    public DataStoreConfiguration load(final String storeName) {
        checkArgument(DEFAULT_DATASTORE_NAME.equalsIgnoreCase(storeName),
            "%s is not valid, %s is the only valid data store name", storeName, DEFAULT_DATASTORE_NAME);
        DataStoreConfiguration configuration = new DataStoreConfiguration();
        configuration.setName(DEFAULT_DATASTORE_NAME);
        configuration.setType(JDBC);
        configuration.setSource(GENERIC_JDBC);
        configuration.setAttributes(ImmutableMap.of(JDBC_URL, JDBC_TEMPLATE_URL));

        log.info("Loaded '{}' data store configuration (GENERIC_JDBC)", storeName);

        return configuration;
    }

}
