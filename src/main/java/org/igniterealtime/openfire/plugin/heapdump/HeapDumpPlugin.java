/*
 * Copyright (C) 2021 Ignite Realtime Foundation. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.igniterealtime.openfire.plugin.heapdump;

import com.sun.management.HotSpotDiagnosticMXBean;
import org.jivesoftware.openfire.XMPPServer;
import org.jivesoftware.openfire.container.Plugin;
import org.jivesoftware.openfire.container.PluginManager;
import org.jivesoftware.util.JiveGlobals;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.lang.management.ManagementFactory;
import java.nio.file.Path;
import java.nio.file.Paths;

public class HeapDumpPlugin implements Plugin
{
    private static final Logger Log = LoggerFactory.getLogger( HeapDumpPlugin.class );


    @Override
    public void initializePlugin( final PluginManager manager, final File pluginDirectory )
    {
    }

    @Override
    public void destroyPlugin()
    {
    }

    /**
     * Dumps the heap to the outputFile file in the same format as the hprof heap dump.
     *
     * If outputFile is a relative path, it is relative to the working directory where the target VM was started.
     *
     * @param outputFile the system-dependent filename
     * @param live if true dump only live objects i.e. objects that are reachable from others
     * @throws IOException if the outputFile already exists, cannot be created, opened, or written to.
     * @throws UnsupportedOperationException if this operation is not supported.
     * @throws IllegalArgumentException if outputFile does not end with ".hprof" suffix.
     * @throws NullPointerException if outputFile is null.
     * @throws SecurityException If a security manager exists and its SecurityManager.checkWrite(String) method denies write access to the named file or the caller does not have ManagmentPermission("control").
     */
    public static void dumpHeap(final String outputFile, final boolean live)
    {
        Log.info( "Generating heap dump in {}", outputFile );
        try {
            String fullOutputPath = Paths.get(JiveGlobals.getHomeDirectory(), outputFile).toAbsolutePath().toString();
            ManagementFactory.newPlatformMXBeanProxy(
                    ManagementFactory.getPlatformMBeanServer(),
                    "com.sun.management:type=HotSpotDiagnostic",
                    HotSpotDiagnosticMXBean.class)
                .dumpHeap(fullOutputPath, live);
            Log.info( "Heap dump generated in {}", outputFile );
        } catch (Exception e) {
            Log.info( "Heap dump generation failed.", e );
        }
    }
}
